<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Profile - LightGRC</title>
    <link href="assets/css/bootstrap.min.css" rel="stylesheet">
    <link href="assets/css/base.css" rel="stylesheet">
    <link href="assets/css/login.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        .profile-header {
            text-align: center;
            margin-bottom: 2rem;
        }
        .profile-avatar {
            width: 120px;
            height: 120px;
            border-radius: 50%;
            margin-bottom: 1rem;
            object-fit: cover;
        }
        .avatar-upload {
            position: relative;
            display: inline-block;
        }
        .avatar-upload input[type="file"] {
            display: none;
        }
        .avatar-upload .btn {
            position: absolute;
            bottom: 0;
            right: 0;
            background: #fff;
            border: 2px solid #007bff;
            border-radius: 50%;
            width: 32px;
            height: 32px;
            padding: 0;
            line-height: 32px;
            text-align: center;
            cursor: pointer;
        }
        .avatar-upload .btn:hover {
            background: #007bff;
            color: #fff;
        }
    </style>
</head>
<body>
    <div class="container-fluid h-100">
        <div class="row h-100">
            <!--- Profile Edit Side --->
            <div class="login-side">
                <div class="login-container">
                    <div class="login-header">
                        <div class="brand-header">
                            <span class="logo-text">Light<span class="highlight">GRC</span></span>
                        </div>
                        <h2>Edit Profile</h2>
                    </div>
                    
                    <!--- Initialize services --->
                    <cfset variables.userService = new UserService()>
                    
                    <!--- Get user data --->
                    <cfset user = variables.userService.getUserByID(session.userID)>
                    
                    <!--- Process profile update --->
                    <cfif structKeyExists(form, "submit")>
                        <cftry>
                            <!--- Validate email --->
                            <cfif !isValid("email", form.email)>
                                <cfset errorMessage = "Please enter a valid email address">
                            <!--- Check email uniqueness --->
                            <cfelseif variables.userService.emailExists(form.email) && form.email neq user.email>
                                <cfset errorMessage = "This email address is already in use">
                            <!--- Update profile --->
                            <cfelse>
                                <cfset variables.userService.updateProfile(
                                    userID = session.userID,
                                    firstName = form.firstName,
                                    lastName = form.lastName,
                                    email = form.email
                                )>
                                
                                <!--- Update session variables --->
                                <cfset session.firstName = form.firstName>
                                <cfset session.lastName = form.lastName>
                                <cfset session.email = form.email>
                                
                                <cflocation url="dashboard.cfm?success=profile_updated" addtoken="false">
                            </cfif>
                            
                            <cfcatch type="any">
                                <!--- Log the error --->
                                <cflog file="profile_update" type="error" text="Profile update error: #cfcatch.message#">
                                <cfset errorMessage = "An error occurred. Please try again.">
                            </cfcatch>
                        </cftry>
                    </cfif>
                    
                    <!--- Show error message if any --->
                    <cfif isDefined("errorMessage")>
                        <div class="alert alert-danger">
                            <i class="fas fa-exclamation-circle"></i>
                            #htmlEditFormat(errorMessage)#
                        </div>
                    </cfif>
                    
                    <!--- Show success message if any --->
                    <cfif structKeyExists(url, "success") && url.success eq "profile_updated">
                        <div class="alert alert-success">
                            <i class="fas fa-check-circle"></i>
                            Your profile has been updated successfully.
                        </div>
                    </cfif>
                    
                    <!--- Profile Edit Form --->
                    <form method="post" action="edit-profile.cfm" enctype="multipart/form-data">
                        <div class="profile-header">
                            <div class="avatar-upload">
                                <img src="#user.avatarURL ?: 'assets/images/default-avatar.png'#" 
                                     alt="Profile Avatar" 
                                     class="profile-avatar" 
                                     id="avatarPreview">
                                <label class="btn">
                                    <i class="fas fa-camera"></i>
                                    <input type="file" 
                                           name="avatar" 
                                           accept="image/*" 
                                           onchange="previewAvatar(this)">
                                </label>
                            </div>
                            <h3>#htmlEditFormat(user.firstName)# #htmlEditFormat(user.lastName)#</h3>
                        </div>
                        
                        <div class="form-group">
                            <label for="firstName">First Name</label>
                            <input type="text" 
                                   class="form-control" 
                                   id="firstName" 
                                   name="firstName" 
                                   value="#htmlEditFormat(user.firstName)#" 
                                   required>
                        </div>
                        
                        <div class="form-group">
                            <label for="lastName">Last Name</label>
                            <input type="text" 
                                   class="form-control" 
                                   id="lastName" 
                                   name="lastName" 
                                   value="#htmlEditFormat(user.lastName)#" 
                                   required>
                        </div>
                        
                        <div class="form-group">
                            <label for="email">Email Address</label>
                            <input type="email" 
                                   class="form-control" 
                                   id="email" 
                                   name="email" 
                                   value="#htmlEditFormat(user.email)#" 
                                   required>
                        </div>
                        
                        <div class="form-group">
                            <button type="submit" name="submit" class="btn btn-primary w-100">
                                Save Changes
                            </button>
                        </div>
                        
                        <div class="text-center">
                            <a href="dashboard.cfm" class="btn btn-link">Cancel</a>
                        </div>
                    </form>
                </div>
            </div>
            
            <!--- Marketing Side --->
            <div class="marketing-side">
                <div class="marketing-content">
                    <h1 class="mega-title">Manage Your Profile</h1>
                    <p class="lead-text">
                        Keep your information up to date
                    </p>
                    
                    <div class="feature-grid">
                        <div class="feature-item">
                            <div class="feature-icon">
                                <i class="fas fa-user"></i>
                            </div>
                            <h3>Personal Info</h3>
                            <p>Update your contact details</p>
                        </div>
                        <div class="feature-item">
                            <div class="feature-icon">
                                <i class="fas fa-image"></i>
                            </div>
                            <h3>Profile Picture</h3>
                            <p>Add a professional photo</p>
                        </div>
                        <div class="feature-item">
                            <div class="feature-icon">
                                <i class="fas fa-envelope"></i>
                            </div>
                            <h3>Email Updates</h3>
                            <p>Stay connected with notifications</p>
                        </div>
                    </div>
                    
                    <div class="next-steps">
                        <h3>Profile Tips</h3>
                        <ul>
                            <li>Use a professional profile picture</li>
                            <li>Keep your contact information current</li>
                            <li>Review your notification preferences</li>
                            <li>Update your password regularly</li>
                        </ul>
                    </div>
                </div>
            </div>
        </div>
    </div>

<script src="assets/js/bootstrap.bundle.min.js"></script>
<script>
function previewAvatar(input) {
    if (input.files && input.files[0]) {
        const reader = new FileReader();
        
        reader.onload = function(e) {
            document.getElementById('avatarPreview').src = e.target.result;
        }
        
        reader.readAsDataURL(input.files[0]);
    }
}
</script>
</body>
</html> 