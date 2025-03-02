component {
    property name="encryptionKey" type="string";
    property name="encryptionAlgorithm" type="string" default="AES/CBC/PKCS5Padding";
    
    public function init() {
        variables.encryptionKey = application.getSecretKey("evidence");
        return this;
    }

    public function uploadEvidence(required numeric controlID, required string description, required array files, required numeric uploadedBy) {
        var evidenceIDs = [];
        
        transaction {
            // Create evidence record
            var evidenceID = queryExecute("
                INSERT INTO audit_evidence (
                    controlID, description, uploadedBy, uploadDate
                ) VALUES (
                    :controlID, :description, :uploadedBy, GETDATE()
                )
                SELECT SCOPE_IDENTITY() as newID
            ", {
                controlID = arguments.controlID,
                description = arguments.description,
                uploadedBy = arguments.uploadedBy
            }, {returntype="array"})[1].newID;

            // Process each file
            for (var file in arguments.files) {
                var fileExtension = listLast(file.serverFile, ".");
                var encryptedFileName = createUUID() & "." & fileExtension;
                var originalFileName = file.clientFile;
                
                // Encrypt and save file
                encryptFile(file.serverDirectory & "/" & file.serverFile, 
                          application.evidencePath & "/" & encryptedFileName);
                
                // Delete temporary file
                fileDelete(file.serverDirectory & "/" & file.serverFile);
                
                // Save file metadata
                queryExecute("
                    INSERT INTO audit_evidence_files (
                        evidenceID, originalFileName, encryptedFileName,
                        fileSize, mimeType, uploadDate
                    ) VALUES (
                        :evidenceID, :originalFileName, :encryptedFileName,
                        :fileSize, :mimeType, GETDATE()
                    )
                ", {
                    evidenceID = evidenceID,
                    originalFileName = originalFileName,
                    encryptedFileName = encryptedFileName,
                    fileSize = file.fileSize,
                    mimeType = file.contentType
                });
            }
            
            evidenceIDs.append(evidenceID);
            
            // Log activity
            logEvidenceActivity(controlID, "evidence_uploaded", "Evidence uploaded: #description#", uploadedBy);
        }
        
        return {
            success = true,
            evidenceIDs = evidenceIDs
        };
    }

    public function getEvidence(required numeric controlID) {
        return queryExecute("
            SELECT e.*,
                   u.firstName + ' ' + u.lastName as uploadedByName,
                   (
                       SELECT COUNT(*)
                       FROM audit_evidence_files
                       WHERE evidenceID = e.evidenceID
                   ) as fileCount
            FROM audit_evidence e
            JOIN users u ON e.uploadedBy = u.userID
            WHERE e.controlID = :controlID
            ORDER BY e.uploadDate DESC
        ", {
            controlID = arguments.controlID
        });
    }

    public function downloadEvidence(required numeric evidenceID, required numeric userID) {
        // Check permissions
        if (!hasAccessToEvidence(arguments.evidenceID, arguments.userID)) {
            return {
                success = false,
                message = "Access denied"
            };
        }

        var fileInfo = queryExecute("
            SELECT ef.*, e.controlID
            FROM audit_evidence_files ef
            JOIN audit_evidence e ON ef.evidenceID = e.evidenceID
            WHERE ef.evidenceID = :evidenceID
        ", {
            evidenceID = arguments.evidenceID
        }, {returntype="array"});

        if (arrayLen(fileInfo)) {
            var file = fileInfo[1];
            var tempDir = getTempDirectory();
            var tempFile = tempDir & createUUID() & "." & listLast(file.originalFileName, ".");
            
            // Decrypt file
            decryptFile(application.evidencePath & "/" & file.encryptedFileName, tempFile);
            
            // Log download
            logEvidenceActivity(file.controlID, "evidence_downloaded", 
                              "Evidence downloaded: #file.originalFileName#", 
                              arguments.userID);
            
            return {
                success = true,
                tempFile = tempFile,
                originalFileName = file.originalFileName,
                mimeType = file.mimeType
            };
        }
        
        return {
            success = false,
            message = "File not found"
        };
    }

    private function encryptFile(required string sourceFile, required string destinationFile) {
        var fileContent = fileReadBinary(arguments.sourceFile);
        var iv = generateIV();
        var encrypted = encrypt(fileContent, variables.encryptionKey, variables.encryptionAlgorithm, iv);
        
        // Prepend IV to encrypted content
        var finalContent = binaryConcat(iv, encrypted);
        fileWrite(arguments.destinationFile, finalContent);
    }

    private function decryptFile(required string sourceFile, required string destinationFile) {
        var fileContent = fileReadBinary(arguments.sourceFile);
        
        // Extract IV and encrypted content
        var iv = binarySlice(fileContent, 1, 16);
        var encrypted = binarySlice(fileContent, 17, len(fileContent));
        
        var decrypted = decrypt(encrypted, variables.encryptionKey, variables.encryptionAlgorithm, iv);
        fileWrite(arguments.destinationFile, decrypted);
    }

    private function generateIV() {
        return generateSecretKey("AES", 128);
    }

    private function binaryConcat(required binary b1, required binary b2) {
        var result = createObject("java", "java.io.ByteArrayOutputStream").init();
        result.write(b1);
        result.write(b2);
        return result.toByteArray();
    }

    private function binarySlice(required binary data, required numeric start, required numeric end) {
        var result = createObject("java", "java.io.ByteArrayOutputStream").init();
        var bytes = data;
        result.write(bytes, javacast("int", start - 1), javacast("int", end - start + 1));
        return result.toByteArray();
    }

    private function hasAccessToEvidence(required numeric evidenceID, required numeric userID) {
        var count = queryExecute("
            SELECT COUNT(*) as cnt
            FROM audit_evidence e
            JOIN audit_controls ac ON e.controlID = ac.controlID
            JOIN audits a ON ac.auditID = a.auditID
            LEFT JOIN audit_team_members atm ON a.auditID = atm.auditID
            WHERE e.evidenceID = :evidenceID
            AND (
                a.managerID = :userID
                OR a.teamLeadID = :userID
                OR atm.userID = :userID
                OR EXISTS (
                    SELECT 1
                    FROM user_roles ur
                    WHERE ur.userID = :userID
                    AND ur.roleID IN (1, 2) -- Super Admin, Auditor roles
                )
            )
        ", {
            evidenceID = arguments.evidenceID,
            userID = arguments.userID
        }, {returntype="array"})[1].cnt;

        return count > 0;
    }

    private function logEvidenceActivity(
        required numeric controlID,
        required string action,
        required string details,
        required numeric userID
    ) {
        queryExecute("
            INSERT INTO audit_activity (
                controlID, action, details,
                userID, activityDate
            ) VALUES (
                :controlID, :action, :details,
                :userID, GETDATE()
            )
        ", {
            controlID = arguments.controlID,
            action = arguments.action,
            details = arguments.details,
            userID = arguments.userID
        });
    }
} 