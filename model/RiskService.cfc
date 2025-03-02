component {
    
    public void function init() {
        variables.securityService = new SecurityService();
        variables.notificationService = new NotificationService();
    }
    
    // Risk Methodology Management
    public struct function getRiskMethodology(required numeric companyID, numeric version = 0) {
        var sql = "
            SELECT m.*, u.firstName & ' ' & u.lastName as createdByName
            FROM risk_methodology m
            INNER JOIN users u ON m.createdBy = u.userID
            WHERE m.companyID = :companyID
            AND (:version = 0 OR m.version = :version)
            ORDER BY m.version DESC
            LIMIT 1
        ";
        
        var methodology = queryExecute(sql, {
            companyID = { value: arguments.companyID, cfsqltype: "cf_sql_integer" },
            version = { value: arguments.version, cfsqltype: "cf_sql_integer" }
        });
        
        if (methodology.recordCount) {
            // Get probability categories
            var probabilities = getProbabilityCategories(methodology.methodologyID);
            
            // Get impact categories
            var impacts = getImpactCategories(methodology.methodologyID);
            
            // Get risk categories
            var categories = getRiskCategories(methodology.methodologyID);
            
            return {
                methodologyID: methodology.methodologyID,
                version: methodology.version,
                status: methodology.status,
                createdBy: methodology.createdByName,
                created: methodology.created,
                probabilities: probabilities,
                impacts: impacts,
                categories: categories
            };
        }
        
        return {};
    }
    
    public array function getProbabilityCategories(required numeric methodologyID) {
        return queryExecute("
            SELECT *
            FROM risk_probability_categories
            WHERE methodologyID = :methodologyID
            ORDER BY level
        ", {
            methodologyID = { value: arguments.methodologyID, cfsqltype: "cf_sql_integer" }
        });
    }
    
    public array function getImpactCategories(required numeric methodologyID) {
        return queryExecute("
            SELECT *
            FROM risk_impact_categories
            WHERE methodologyID = :methodologyID
            ORDER BY level
        ", {
            methodologyID = { value: arguments.methodologyID, cfsqltype: "cf_sql_integer" }
        });
    }
    
    public array function getRiskCategories(required numeric methodologyID) {
        return queryExecute("
            SELECT *
            FROM risk_categories
            WHERE methodologyID = :methodologyID
            ORDER BY name
        ", {
            methodologyID = { value: arguments.methodologyID, cfsqltype: "cf_sql_integer" }
        });
    }
    
    public numeric function saveMethodology(required struct methodology) {
        transaction {
            try {
                // Insert new methodology version
                var sql = "
                    INSERT INTO risk_methodology (
                        companyID, version, status, createdBy, created
                    )
                    SELECT 
                        :companyID,
                        COALESCE(MAX(version), 0) + 1,
                        'pending',
                        :userID,
                        NOW()
                    FROM risk_methodology
                    WHERE companyID = :companyID
                    RETURNING methodologyID, version
                ";
                
                var newMethodology = queryExecute(sql, {
                    companyID = { value: methodology.companyID, cfsqltype: "cf_sql_integer" },
                    userID = { value: session.userID, cfsqltype: "cf_sql_integer" }
                });
                
                var methodologyID = newMethodology.methodologyID;
                
                // Save probability categories
                for (var prob in methodology.probabilities) {
                    queryExecute("
                        INSERT INTO risk_probability_categories (
                            methodologyID, name, description, level, color
                        ) VALUES (
                            :methodologyID, :name, :description, :level, :color
                        )
                    ", {
                        methodologyID = { value: methodologyID, cfsqltype: "cf_sql_integer" },
                        name = { value: prob.name, cfsqltype: "cf_sql_varchar" },
                        description = { value: prob.description, cfsqltype: "cf_sql_varchar" },
                        level = { value: prob.level, cfsqltype: "cf_sql_integer" },
                        color = { value: prob.color, cfsqltype: "cf_sql_varchar" }
                    });
                }
                
                // Save impact categories
                for (var impact in methodology.impacts) {
                    queryExecute("
                        INSERT INTO risk_impact_categories (
                            methodologyID, name, description, level, color
                        ) VALUES (
                            :methodologyID, :name, :description, :level, :color
                        )
                    ", {
                        methodologyID = { value: methodologyID, cfsqltype: "cf_sql_integer" },
                        name = { value: impact.name, cfsqltype: "cf_sql_varchar" },
                        description = { value: impact.description, cfsqltype: "cf_sql_varchar" },
                        level = { value: impact.level, cfsqltype: "cf_sql_integer" },
                        color = { value: impact.color, cfsqltype: "cf_sql_varchar" }
                    });
                }
                
                // Save risk categories
                for (var cat in methodology.categories) {
                    queryExecute("
                        INSERT INTO risk_categories (
                            methodologyID, name, description
                        ) VALUES (
                            :methodologyID, :name, :description
                        )
                    ", {
                        methodologyID = { value: methodologyID, cfsqltype: "cf_sql_integer" },
                        name = { value: cat.name, cfsqltype: "cf_sql_varchar" },
                        description = { value: cat.description, cfsqltype: "cf_sql_varchar" }
                    });
                }
                
                // Notify approvers
                notificationService.sendSystemNotification(
                    type: "risk_methodology_approval",
                    data: {
                        title: "New Risk Methodology Version Pending Approval",
                        message: "A new risk methodology version has been created and requires approval.",
                        methodologyID: methodologyID,
                        version: newMethodology.version,
                        companyName: methodology.companyName
                    },
                    userGroup: "risk.approve"
                );
                
                return methodologyID;
            }
            catch (any e) {
                transaction action="rollback";
                rethrow;
            }
        }
    }
    
    // Asset Inventory Management
    public array function getAssets(
        required numeric companyID,
        string status = "",
        string type = "",
        string classification = "",
        numeric ownerID = 0
    ) {
        var sql = "
            SELECT a.*,
                   o.firstName & ' ' & o.lastName as ownerName,
                   c.firstName & ' ' & c.lastName as custodianName
            FROM assets a
            INNER JOIN users o ON a.ownerID = o.userID
            INNER JOIN users c ON a.custodianID = c.userID
            WHERE a.companyID = :companyID
        ";
        
        var params = {
            companyID = { value: arguments.companyID, cfsqltype: "cf_sql_integer" }
        };
        
        if (len(arguments.status)) {
            sql &= " AND a.status = :status";
            params.status = { value: arguments.status, cfsqltype: "cf_sql_varchar" };
        }
        
        if (len(arguments.type)) {
            sql &= " AND a.type = :type";
            params.type = { value: arguments.type, cfsqltype: "cf_sql_varchar" };
        }
        
        if (len(arguments.classification)) {
            sql &= " AND a.classification = :classification";
            params.classification = { value: arguments.classification, cfsqltype: "cf_sql_varchar" };
        }
        
        if (arguments.ownerID > 0) {
            sql &= " AND a.ownerID = :ownerID";
            params.ownerID = { value: arguments.ownerID, cfsqltype: "cf_sql_integer" };
        }
        
        sql &= " ORDER BY a.name";
        
        return queryExecute(sql, params);
    }
    
    public struct function getAsset(required numeric assetID) {
        var sql = "
            SELECT a.*,
                   o.firstName & ' ' & o.lastName as ownerName,
                   c.firstName & ' ' & c.lastName as custodianName
            FROM assets a
            INNER JOIN users o ON a.ownerID = o.userID
            INNER JOIN users c ON a.custodianID = c.userID
            WHERE a.assetID = :assetID
        ";
        
        var asset = queryExecute(sql, {
            assetID = { value: arguments.assetID, cfsqltype: "cf_sql_integer" }
        });
        
        if (asset.recordCount) {
            return {
                assetID: asset.assetID,
                name: asset.name,
                description: asset.description,
                status: asset.status,
                type: asset.type,
                value: asset.value,
                classification: asset.classification,
                ownerID: asset.ownerID,
                ownerName: asset.ownerName,
                custodianID: asset.custodianID,
                custodianName: asset.custodianName
            };
        }
        
        return {};
    }
    
    public void function saveAsset(required struct asset) {
        if (asset.assetID > 0) {
            // Update existing asset
            queryExecute("
                UPDATE assets
                SET name = :name,
                    description = :description,
                    status = :status,
                    type = :type,
                    value = :value,
                    classification = :classification,
                    ownerID = :ownerID,
                    custodianID = :custodianID,
                    modified = NOW()
                WHERE assetID = :assetID
                AND companyID = :companyID
            ", {
                assetID = { value: asset.assetID, cfsqltype: "cf_sql_integer" },
                companyID = { value: asset.companyID, cfsqltype: "cf_sql_integer" },
                name = { value: asset.name, cfsqltype: "cf_sql_varchar" },
                description = { value: asset.description, cfsqltype: "cf_sql_varchar" },
                status = { value: asset.status, cfsqltype: "cf_sql_varchar" },
                type = { value: asset.type, cfsqltype: "cf_sql_varchar" },
                value = { value: asset.value, cfsqltype: "cf_sql_decimal" },
                classification = { value: asset.classification, cfsqltype: "cf_sql_varchar" },
                ownerID = { value: asset.ownerID, cfsqltype: "cf_sql_integer" },
                custodianID = { value: asset.custodianID, cfsqltype: "cf_sql_integer" }
            });
        } else {
            // Insert new asset
            queryExecute("
                INSERT INTO assets (
                    companyID, name, description, status, type,
                    value, classification, ownerID, custodianID, created
                ) VALUES (
                    :companyID, :name, :description, :status, :type,
                    :value, :classification, :ownerID, :custodianID, NOW()
                )
            ", {
                companyID = { value: asset.companyID, cfsqltype: "cf_sql_integer" },
                name = { value: asset.name, cfsqltype: "cf_sql_varchar" },
                description = { value: asset.description, cfsqltype: "cf_sql_varchar" },
                status = { value: asset.status, cfsqltype: "cf_sql_varchar" },
                type = { value: asset.type, cfsqltype: "cf_sql_varchar" },
                value = { value: asset.value, cfsqltype: "cf_sql_decimal" },
                classification = { value: asset.classification, cfsqltype: "cf_sql_varchar" },
                ownerID = { value: asset.ownerID, cfsqltype: "cf_sql_integer" },
                custodianID = { value: asset.custodianID, cfsqltype: "cf_sql_integer" }
            });
        }
    }
    
    // Risk Assessment Management
    public array function getRisks(required numeric companyID) {
        var sql = "
            SELECT r.*, 
                   rc.name as categoryName,
                   rp.name as probabilityName,
                   ri.name as impactName,
                   rp.level * ri.level as riskLevel,
                   GROUP_CONCAT(a.name) as assetList,
                   COALESCE(rt.status, 'not_started') as treatmentStatus
            FROM risks r
            INNER JOIN risk_categories rc ON r.categoryID = rc.categoryID
            INNER JOIN risk_probability_categories rp ON r.probabilityID = rp.categoryID
            INNER JOIN risk_impact_categories ri ON r.impactID = ri.categoryID
            LEFT JOIN risk_assets ra ON r.riskID = ra.riskID
            LEFT JOIN assets a ON ra.assetID = a.assetID
            LEFT JOIN risk_treatments rt ON r.riskID = rt.riskID
            WHERE r.companyID = :companyID
            GROUP BY r.riskID
            ORDER BY riskLevel DESC
        ";
        
        return queryExecute(sql, {
            companyID = { value: arguments.companyID, cfsqltype: "cf_sql_integer" }
        });
    }
    
    public array function getRisksByLevel(required numeric companyID) {
        var sql = "
            SELECT rp.level as probability,
                   ri.level as impact,
                   COUNT(*) as count
            FROM risks r
            INNER JOIN risk_probability_categories rp ON r.probabilityID = rp.categoryID
            INNER JOIN risk_impact_categories ri ON r.impactID = ri.categoryID
            WHERE r.companyID = :companyID
            GROUP BY rp.level, ri.level
            ORDER BY rp.level, ri.level
        ";
        
        return queryExecute(sql, {
            companyID = { value: arguments.companyID, cfsqltype: "cf_sql_integer" }
        });
    }
    
    public struct function getRisk(required numeric riskID) {
        var sql = "
            SELECT r.*, 
                   GROUP_CONCAT(ra.assetID) as assetIDs
            FROM risks r
            LEFT JOIN risk_assets ra ON r.riskID = ra.riskID
            WHERE r.riskID = :riskID
            GROUP BY r.riskID
        ";
        
        var risk = queryExecute(sql, {
            riskID = { value: arguments.riskID, cfsqltype: "cf_sql_integer" }
        });
        
        if (risk.recordCount) {
            return {
                riskID: risk.riskID,
                title: risk.title,
                description: risk.description,
                categoryID: risk.categoryID,
                probabilityID: risk.probabilityID,
                impactID: risk.impactID,
                assetIDs: risk.assetIDs
            };
        }
        
        return {};
    }
    
    public numeric function saveRisk(required struct risk) {
        transaction {
            try {
                if (risk.riskID > 0) {
                    // Update existing risk
                    queryExecute("
                        UPDATE risks
                        SET title = :title,
                            description = :description,
                            categoryID = :categoryID,
                            probabilityID = :probabilityID,
                            impactID = :impactID,
                            modified = NOW()
                        WHERE riskID = :riskID
                        AND companyID = :companyID
                    ", {
                        riskID = { value: risk.riskID, cfsqltype: "cf_sql_integer" },
                        companyID = { value: risk.companyID, cfsqltype: "cf_sql_integer" },
                        title = { value: risk.title, cfsqltype: "cf_sql_varchar" },
                        description = { value: risk.description, cfsqltype: "cf_sql_varchar" },
                        categoryID = { value: risk.categoryID, cfsqltype: "cf_sql_integer" },
                        probabilityID = { value: risk.probabilityID, cfsqltype: "cf_sql_integer" },
                        impactID = { value: risk.impactID, cfsqltype: "cf_sql_integer" }
                    });
                    
                    // Delete existing asset associations
                    queryExecute("
                        DELETE FROM risk_assets
                        WHERE riskID = :riskID
                    ", {
                        riskID = { value: risk.riskID, cfsqltype: "cf_sql_integer" }
                    });
                    
                    var riskID = risk.riskID;
                } else {
                    // Insert new risk
                    var result = queryExecute("
                        INSERT INTO risks (
                            companyID, title, description, categoryID,
                            probabilityID, impactID, created
                        ) VALUES (
                            :companyID, :title, :description, :categoryID,
                            :probabilityID, :impactID, NOW()
                        )
                        RETURNING riskID
                    ", {
                        companyID = { value: risk.companyID, cfsqltype: "cf_sql_integer" },
                        title = { value: risk.title, cfsqltype: "cf_sql_varchar" },
                        description = { value: risk.description, cfsqltype: "cf_sql_varchar" },
                        categoryID = { value: risk.categoryID, cfsqltype: "cf_sql_integer" },
                        probabilityID = { value: risk.probabilityID, cfsqltype: "cf_sql_integer" },
                        impactID = { value: risk.impactID, cfsqltype: "cf_sql_integer" }
                    });
                    
                    var riskID = result.riskID;
                }
                
                // Add asset associations
                for (var assetID in listToArray(risk.assetIDs)) {
                    queryExecute("
                        INSERT INTO risk_assets (riskID, assetID)
                        VALUES (:riskID, :assetID)
                    ", {
                        riskID = { value: riskID, cfsqltype: "cf_sql_integer" },
                        assetID = { value: assetID, cfsqltype: "cf_sql_integer" }
                    });
                }
                
                return riskID;
            }
            catch (any e) {
                transaction action="rollback";
                rethrow;
            }
        }
    }
    
    public struct function getTreatment(required numeric riskID) {
        var sql = "
            SELECT t.*, GROUP_CONCAT(c.control) as controls
            FROM risk_treatments t
            LEFT JOIN risk_controls c ON t.treatmentID = c.treatmentID
            WHERE t.riskID = :riskID
            GROUP BY t.treatmentID
        ";
        
        var treatment = queryExecute(sql, {
            riskID = { value: arguments.riskID, cfsqltype: "cf_sql_integer" }
        });
        
        if (treatment.recordCount) {
            return {
                treatmentID: treatment.treatmentID,
                strategy: treatment.strategy,
                status: treatment.status,
                plan: treatment.plan,
                dueDate: treatment.dueDate,
                assignedTo: treatment.assignedTo,
                controls: listToArray(treatment.controls)
            };
        }
        
        return {
            strategy: "mitigate",
            status: "not_started",
            plan: "",
            dueDate: "",
            assignedTo: 0,
            controls: []
        };
    }
    
    public void function saveTreatment(required struct treatment) {
        transaction {
            try {
                // Save treatment plan
                var result = queryExecute("
                    INSERT INTO risk_treatments (
                        riskID, strategy, status, plan,
                        dueDate, assignedTo, created
                    ) VALUES (
                        :riskID, :strategy, :status, :plan,
                        :dueDate, :assignedTo, NOW()
                    )
                    ON DUPLICATE KEY UPDATE
                        strategy = VALUES(strategy),
                        status = VALUES(status),
                        plan = VALUES(plan),
                        dueDate = VALUES(dueDate),
                        assignedTo = VALUES(assignedTo),
                        modified = NOW()
                    RETURNING treatmentID
                ", {
                    riskID = { value: treatment.riskID, cfsqltype: "cf_sql_integer" },
                    strategy = { value: treatment.strategy, cfsqltype: "cf_sql_varchar" },
                    status = { value: treatment.status, cfsqltype: "cf_sql_varchar" },
                    plan = { value: treatment.plan, cfsqltype: "cf_sql_varchar" },
                    dueDate = { value: treatment.dueDate, cfsqltype: "cf_sql_date" },
                    assignedTo = { value: treatment.assignedTo, cfsqltype: "cf_sql_integer" }
                });
                
                var treatmentID = result.treatmentID;
                
                // Delete existing controls
                queryExecute("
                    DELETE FROM risk_controls
                    WHERE treatmentID = :treatmentID
                ", {
                    treatmentID = { value: treatmentID, cfsqltype: "cf_sql_integer" }
                });
                
                // Add new controls
                for (var control in treatment.controls) {
                    if (len(trim(control))) {
                        queryExecute("
                            INSERT INTO risk_controls (treatmentID, control)
                            VALUES (:treatmentID, :control)
                        ", {
                            treatmentID = { value: treatmentID, cfsqltype: "cf_sql_integer" },
                            control = { value: control, cfsqltype: "cf_sql_varchar" }
                        });
                    }
                }
                
                // Notify assigned user
                notificationService.sendSystemNotification(
                    type: "risk_treatment_assigned",
                    data: {
                        title: "Risk Treatment Assigned",
                        message: "You have been assigned a risk treatment plan.",
                        riskID: treatment.riskID,
                        dueDate: treatment.dueDate
                    },
                    userID: treatment.assignedTo
                );
            }
            catch (any e) {
                transaction action="rollback";
                rethrow;
            }
        }
    }
    
    // Risk Appetite Management
    public struct function getRiskAppetiteSettings(required numeric companyID) {
        var sql = "
            SELECT ra.*, rc.name as categoryName
            FROM risk_appetite ra
            INNER JOIN risk_categories rc ON ra.categoryID = rc.categoryID
            WHERE ra.companyID = :companyID
        ";
        
        var settings = queryExecute(sql, {
            companyID = { value: arguments.companyID, cfsqltype: "cf_sql_integer" }
        });
        
        var result = {};
        for (var setting in settings) {
            result[setting.categoryID] = {
                appetite_level: setting.appetite_level,
                tolerance_threshold: setting.tolerance_threshold,
                description: setting.description
            };
        }
        
        return result;
    }
    
    public void function saveAppetiteSettings(required struct settings) {
        transaction {
            try {
                for (var categoryID in settings) {
                    queryExecute("
                        INSERT INTO risk_appetite (
                            companyID, categoryID, appetite_level,
                            tolerance_threshold, description
                        ) VALUES (
                            :companyID, :categoryID, :appetite_level,
                            :tolerance_threshold, :description
                        )
                        ON DUPLICATE KEY UPDATE
                            appetite_level = VALUES(appetite_level),
                            tolerance_threshold = VALUES(tolerance_threshold),
                            description = VALUES(description)
                    ", {
                        companyID = { value: settings.companyID, cfsqltype: "cf_sql_integer" },
                        categoryID = { value: categoryID, cfsqltype: "cf_sql_integer" },
                        appetite_level = { value: settings["appetite_" & categoryID], cfsqltype: "cf_sql_varchar" },
                        tolerance_threshold = { value: settings["tolerance_" & categoryID], cfsqltype: "cf_sql_integer" },
                        description = { value: settings["description_" & categoryID], cfsqltype: "cf_sql_varchar" }
                    });
                }
            }
            catch (any e) {
                transaction action="rollback";
                rethrow;
            }
        }
    }
    
    // Risk Review Management
    public array function getPendingReviews(required numeric companyID) {
        var sql = "
            SELECT r.*, rc.name as categoryName,
                   u.firstName & ' ' & u.lastName as submittedByName,
                   rp.level * ri.level as riskLevel
            FROM risks r
            INNER JOIN risk_categories rc ON r.categoryID = rc.categoryID
            INNER JOIN risk_probability_categories rp ON r.probabilityID = rp.categoryID
            INNER JOIN risk_impact_categories ri ON r.impactID = ri.categoryID
            INNER JOIN users u ON r.createdBy = u.userID
            LEFT JOIN risk_reviews rr ON r.riskID = rr.riskID
            WHERE r.companyID = :companyID
            AND (rr.reviewID IS NULL OR rr.status = 'needs_revision')
            ORDER BY r.created DESC
        ";
        
        return queryExecute(sql, {
            companyID = { value: arguments.companyID, cfsqltype: "cf_sql_integer" }
        });
    }
    
    public array function getReviewHistory(required numeric companyID) {
        var sql = "
            SELECT r.title, rc.name as categoryName,
                   rr.status, rr.comments, rr.review_date,
                   u.firstName & ' ' & u.lastName as reviewerName
            FROM risk_reviews rr
            INNER JOIN risks r ON rr.riskID = r.riskID
            INNER JOIN risk_categories rc ON r.categoryID = rc.categoryID
            INNER JOIN users u ON rr.reviewerID = u.userID
            WHERE r.companyID = :companyID
            ORDER BY rr.review_date DESC
        ";
        
        return queryExecute(sql, {
            companyID = { value: arguments.companyID, cfsqltype: "cf_sql_integer" }
        });
    }
    
    public void function submitReview(required struct review) {
        transaction {
            try {
                queryExecute("
                    INSERT INTO risk_reviews (
                        riskID, reviewerID, status,
                        comments, review_date
                    ) VALUES (
                        :riskID, :reviewerID, :status,
                        :comments, NOW()
                    )
                ", {
                    riskID = { value: review.riskID, cfsqltype: "cf_sql_integer" },
                    reviewerID = { value: session.userID, cfsqltype: "cf_sql_integer" },
                    status = { value: review.status, cfsqltype: "cf_sql_varchar" },
                    comments = { value: review.comments, cfsqltype: "cf_sql_varchar" }
                });
                
                // Record risk history
                var risk = getRisk(review.riskID);
                queryExecute("
                    INSERT INTO risk_history (
                        riskID, probabilityID, impactID,
                        recorded_by, recorded_date
                    ) VALUES (
                        :riskID, :probabilityID, :impactID,
                        :recorded_by, NOW()
                    )
                ", {
                    riskID = { value: review.riskID, cfsqltype: "cf_sql_integer" },
                    probabilityID = { value: risk.probabilityID, cfsqltype: "cf_sql_integer" },
                    impactID = { value: risk.impactID, cfsqltype: "cf_sql_integer" },
                    recorded_by = { value: session.userID, cfsqltype: "cf_sql_integer" }
                });
                
                // Notify risk owner
                notificationService.sendSystemNotification(
                    type: "risk_review_completed",
                    data: {
                        title: "Risk Review Completed",
                        message: "Your risk has been reviewed. Status: " & review.status,
                        riskID: review.riskID,
                        comments: review.comments
                    },
                    userID: risk.createdBy
                );
            }
            catch (any e) {
                transaction action="rollback";
                rethrow;
            }
        }
    }
    
    // Risk Analytics
    public struct function getRiskAnalytics(required numeric companyID) {
        var result = {
            totalRisks: 0,
            highRisks: 0,
            aboveTolerance: 0,
            treatedRisks: 0,
            categoryLabels: [],
            categoryData: [],
            treatmentLabels: ['Mitigate', 'Transfer', 'Avoid', 'Accept'],
            treatmentData: [],
            treatmentProgress: []
        };
        
        // Get risk counts
        var counts = queryExecute("
            SELECT COUNT(*) as total,
                   SUM(CASE WHEN rp.level * ri.level > 12 THEN 1 ELSE 0 END) as highRisks,
                   SUM(CASE WHEN rt.status = 'completed' THEN 1 ELSE 0 END) as treated
            FROM risks r
            INNER JOIN risk_probability_categories rp ON r.probabilityID = rp.categoryID
            INNER JOIN risk_impact_categories ri ON r.impactID = ri.categoryID
            LEFT JOIN risk_treatments rt ON r.riskID = rt.riskID
            WHERE r.companyID = :companyID
        ", {
            companyID = { value: arguments.companyID, cfsqltype: "cf_sql_integer" }
        });
        
        result.totalRisks = counts.total;
        result.highRisks = counts.highRisks;
        result.treatedRisks = counts.treated;
        
        // Get risks above tolerance
        var tolerance = queryExecute("
            SELECT COUNT(*) as above
            FROM risks r
            INNER JOIN risk_probability_categories rp ON r.probabilityID = rp.categoryID
            INNER JOIN risk_impact_categories ri ON r.impactID = ri.categoryID
            INNER JOIN risk_appetite ra ON r.categoryID = ra.categoryID
            WHERE r.companyID = :companyID
            AND rp.level * ri.level > ra.tolerance_threshold
        ", {
            companyID = { value: arguments.companyID, cfsqltype: "cf_sql_integer" }
        });
        
        result.aboveTolerance = tolerance.above;
        
        // Get category distribution
        var categories = queryExecute("
            SELECT rc.name, COUNT(*) as count
            FROM risks r
            INNER JOIN risk_categories rc ON r.categoryID = rc.categoryID
            WHERE r.companyID = :companyID
            GROUP BY rc.categoryID, rc.name
        ", {
            companyID = { value: arguments.companyID, cfsqltype: "cf_sql_integer" }
        });
        
        for (var category in categories) {
            arrayAppend(result.categoryLabels, category.name);
            arrayAppend(result.categoryData, category.count);
        }
        
        // Get treatment distribution
        var treatments = queryExecute("
            SELECT strategy, COUNT(*) as count,
                   ROUND(AVG(CASE WHEN status = 'completed' THEN 100
                            WHEN status = 'in_progress' THEN 50
                            WHEN status = 'planned' THEN 25
                            ELSE 0 END)) as progress
            FROM risk_treatments
            WHERE riskID IN (SELECT riskID FROM risks WHERE companyID = :companyID)
            GROUP BY strategy
        ", {
            companyID = { value: arguments.companyID, cfsqltype: "cf_sql_integer" }
        });
        
        for (var treatment in treatments) {
            arrayAppend(result.treatmentData, treatment.count);
            arrayAppend(result.treatmentProgress, {
                strategy: treatment.strategy,
                count: treatment.count,
                percentage: treatment.progress
            });
        }
        
        return result;
    }
    
    public struct function getRiskTrends(required numeric companyID) {
        var result = {
            labels: [],
            highRisks: [],
            mediumRisks: [],
            lowRisks: []
        };
        
        // Get last 12 months of data
        var trends = queryExecute("
            SELECT DATE_FORMAT(recorded_date, '%Y-%m') as month,
                   SUM(CASE WHEN rp.level * ri.level > 12 THEN 1 ELSE 0 END) as high,
                   SUM(CASE WHEN rp.level * ri.level BETWEEN 5 AND 12 THEN 1 ELSE 0 END) as medium,
                   SUM(CASE WHEN rp.level * ri.level < 5 THEN 1 ELSE 0 END) as low
            FROM risk_history rh
            INNER JOIN risk_probability_categories rp ON rh.probabilityID = rp.categoryID
            INNER JOIN risk_impact_categories ri ON rh.impactID = ri.categoryID
            INNER JOIN risks r ON rh.riskID = r.riskID
            WHERE r.companyID = :companyID
            AND rh.recorded_date >= DATE_SUB(NOW(), INTERVAL 12 MONTH)
            GROUP BY month
            ORDER BY month
        ", {
            companyID = { value: arguments.companyID, cfsqltype: "cf_sql_integer" }
        });
        
        for (var trend in trends) {
            arrayAppend(result.labels, trend.month);
            arrayAppend(result.highRisks, trend.high);
            arrayAppend(result.mediumRisks, trend.medium);
            arrayAppend(result.lowRisks, trend.low);
        }
        
        return result;
    }
    
    public array function getRiskKPIs(required numeric companyID) {
        return queryExecute("
            SELECT k.*,
                   CASE WHEN k.actual_value > LAG(k.actual_value) 
                        OVER (PARTITION BY k.name ORDER BY k.measurement_date)
                        THEN 'up'
                        WHEN k.actual_value < LAG(k.actual_value)
                        OVER (PARTITION BY k.name ORDER BY k.measurement_date)
                        THEN 'down'
                        ELSE 'stable'
                   END as trend
            FROM risk_kpis k
            WHERE k.companyID = :companyID
            AND k.measurement_date = (
                SELECT MAX(measurement_date)
                FROM risk_kpis
                WHERE companyID = :companyID
            )
        ", {
            companyID = { value: arguments.companyID, cfsqltype: "cf_sql_integer" }
        });
    }
    
    public struct function exportDashboard(required numeric companyID, string format = "pdf") {
        var analytics = getRiskAnalytics(arguments.companyID);
        var trends = getRiskTrends(arguments.companyID);
        var kpis = getRiskKPIs(arguments.companyID);
        var topRisks = getRisks(arguments.companyID);
        
        // Create PDF using CFDocument
        savecontent variable="pdfContent" {
            include "/admin/risk/executive_pdf.cfm";
        }
        
        var fileName = "risk_dashboard_#dateFormat(now(), 'yyyymmdd')#_#timeFormat(now(), 'HHmmss')#.pdf";
        var filePath = expandPath("/temp/#fileName#");
        
        // Generate PDF
        cfdocument(format="PDF", filename="#filePath#", overwrite="true") {
            writeOutput(pdfContent);
        }
        
        return {
            success: true,
            fileName: fileName,
            filePath: filePath
        };
    }
} 