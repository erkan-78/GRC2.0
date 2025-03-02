component {
    
    public void function init() {
        variables.encryptionService = new EncryptionService();
    }
    
    public struct function saveFile(
        required string fileName,
        required string fileType,
        required any content,
        required numeric companyID,
        string category = "general"
    ) {
        var fileExtension = listLast(arguments.fileName, ".");
        var uniqueFileName = createUUID() & "." & fileExtension;
        var storagePath = expandPath("/storage/#arguments.companyID#/#arguments.category#/");
        
        // Create directory if it doesn't exist
        if (!directoryExists(storagePath)) {
            directoryCreate(storagePath);
        }
        
        // Save file metadata
        var result = queryExecute("
            INSERT INTO files (
                companyID, originalName, storedName,
                fileType, category, uploadedBy,
                uploadDate
            ) VALUES (
                :companyID, :originalName, :storedName,
                :fileType, :category, :userID,
                NOW()
            )
            RETURNING fileID
        ", {
            companyID = { value: arguments.companyID, cfsqltype: "cf_sql_integer" },
            originalName = { value: arguments.fileName, cfsqltype: "cf_sql_varchar" },
            storedName = { value: uniqueFileName, cfsqltype: "cf_sql_varchar" },
            fileType = { value: arguments.fileType, cfsqltype: "cf_sql_varchar" },
            category = { value: arguments.category, cfsqltype: "cf_sql_varchar" },
            userID = { value: session.userID, cfsqltype: "cf_sql_integer" }
        });
        
        // Save encrypted file
        fileWrite(storagePath & uniqueFileName, arguments.content);
        
        return {
            fileID: result.fileID,
            storedName: uniqueFileName,
            storagePath: storagePath
        };
    }
    
    public any function getFile(required numeric fileID) {
        var fileInfo = queryExecute("
            SELECT f.*
            FROM files f
            WHERE f.fileID = :fileID
            AND f.companyID = :companyID
        ", {
            fileID = { value: arguments.fileID, cfsqltype: "cf_sql_integer" },
            companyID = { value: session.companyID, cfsqltype: "cf_sql_integer" }
        });
        
        if (fileInfo.recordCount) {
            var storagePath = expandPath("/storage/#fileInfo.companyID#/#fileInfo.category#/");
            var filePath = storagePath & fileInfo.storedName;
            
            if (fileExists(filePath)) {
                // Read encrypted content
                var encryptedContent = fileRead(filePath);
                
                // Decrypt content
                var decryptedContent = encryptionService.decryptFile(
                    fileContent: encryptedContent,
                    companyID: fileInfo.companyID
                );
                
                return {
                    success: true,
                    fileName: fileInfo.originalName,
                    fileType: fileInfo.fileType,
                    content: decryptedContent
                };
            }
        }
        
        return {
            success: false,
            message: "File not found or access denied"
        };
    }
    
    public void function deleteFile(required numeric fileID) {
        var fileInfo = queryExecute("
            SELECT f.*
            FROM files f
            WHERE f.fileID = :fileID
            AND f.companyID = :companyID
        ", {
            fileID = { value: arguments.fileID, cfsqltype: "cf_sql_integer" },
            companyID = { value: session.companyID, cfsqltype: "cf_sql_integer" }
        });
        
        if (fileInfo.recordCount) {
            var storagePath = expandPath("/storage/#fileInfo.companyID#/#fileInfo.category#/");
            var filePath = storagePath & fileInfo.storedName;
            
            // Delete physical file
            if (fileExists(filePath)) {
                fileDelete(filePath);
            }
            
            // Delete file record
            queryExecute("
                DELETE FROM files
                WHERE fileID = :fileID
            ", {
                fileID = { value: arguments.fileID, cfsqltype: "cf_sql_integer" }
            });
        }
    }
    
    public array function getFilesByCategory(
        required numeric companyID,
        required string category
    ) {
        return queryExecute("
            SELECT f.*,
                   u.firstName & ' ' & u.lastName as uploaderName
            FROM files f
            INNER JOIN users u ON f.uploadedBy = u.userID
            WHERE f.companyID = :companyID
            AND f.category = :category
            ORDER BY f.uploadDate DESC
        ", {
            companyID = { value: arguments.companyID, cfsqltype: "cf_sql_integer" },
            category = { value: arguments.category, cfsqltype: "cf_sql_varchar" }
        });
    }
} 