<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:include page="includes/header.jsp" />

<div class="auth-container">
    <div class="auth-card">
        <div class="auth-header">
            <div class="auth-header-icon">
                <i class="fas fa-key"></i>
            </div>
            <h1 class="auth-title">Reset Account Password</h1>
            <p class="auth-sub">Enter your account identifier to configure a new password</p>
        </div>

        <% String userType = (String) request.getAttribute("userType");
           if (userType == null || userType.trim().isEmpty()) {
               userType = request.getParameter("userType");
           }
           if (userType == null || (!"student".equalsIgnoreCase(userType) && !"admin".equalsIgnoreCase(userType))) {
               userType = "admin";
           }
           String errorMessage = (String) request.getAttribute("errorMessage"); %>

        <% if (errorMessage != null && !errorMessage.isEmpty()) { %>
            <div class="alert alert-danger mb-3" role="alert">
                <i class="fas fa-circle-exclamation me-2"></i><%= errorMessage %>
            </div>
        <% } %>

        <form action="<%= request.getContextPath() %>/ForgotPasswordServlet" method="post" onsubmit="return validateResetForm();">
            <div class="mb-3">
                <label for="userTypeSelect" class="form-label">Account Role</label>
                <div class="input-group">
                    <span class="input-group-text"><i class="fas fa-users"></i></span>
                    <select class="form-select" name="userType" id="userTypeSelect" required onchange="updateIdentifierLabel()">
                        <option value="admin" <%= "admin".equals(userType) ? "selected" : "" %>>Administrator</option>
                        <option value="student" <%= "student".equals(userType) ? "selected" : "" %>>Student Member</option>
                    </select>
                </div>
            </div>

            <div class="mb-3">
                <label for="identifierInput" class="form-label" id="identifierLabel"><%= "admin".equals(userType) ? "Admin Username" : "Student Email Address" %></label>
                <div class="input-group">
                    <span class="input-group-text"><i class="fas fa-id-card"></i></span>
                    <input type="text" id="identifierInput" class="form-control" name="identifier" required placeholder="<%= "admin".equals(userType) ? "e.g. admin" : "e.g. student@example.edu" %>">
                </div>
            </div>

            <div class="mb-3">
                <label for="resetNewPass" class="form-label">New Password</label>
                <div class="input-group">
                    <span class="input-group-text"><i class="fas fa-lock"></i></span>
                    <input type="password" id="resetNewPass" class="form-control" name="newPassword" required placeholder="Minimum 6 characters" autocomplete="new-password">
                </div>
            </div>

            <div class="mb-4">
                <label for="resetConfirmPass" class="form-label">Confirm New Password</label>
                <div class="input-group">
                    <span class="input-group-text"><i class="fas fa-shield-check"></i></span>
                    <input type="password" id="resetConfirmPass" class="form-control" name="confirmPassword" required placeholder="Re-type new password" autocomplete="new-password">
                </div>
            </div>

            <button type="submit" class="btn-lib-primary w-100 py-2">
                <i class="fas fa-key me-1"></i> Update Account Password
            </button>
        </form>

        <div class="auth-footer">
            <a href="<%= request.getContextPath() %>/" class="text-decoration-none small text-muted">
                <i class="fas fa-arrow-left me-1"></i> Return to Homepage
            </a>
        </div>
    </div>
</div>

<script>
function updateIdentifierLabel() {
    var select = document.getElementById("userTypeSelect");
    var label = document.getElementById("identifierLabel");
    var input = document.getElementById("identifierInput");
    if (select.value === "admin") {
        label.innerText = "Admin Username";
        input.placeholder = "e.g. admin";
    } else {
        label.innerText = "Student Email Address";
        input.placeholder = "e.g. student@example.edu";
    }
}

function validateResetForm() {
    var p1 = document.getElementById("resetNewPass").value;
    var p2 = document.getElementById("resetConfirmPass").value;
    if (p1.length < 6) {
        sweetConfirm('Weak Password', 'Password must be at least 6 characters long.', 'OK', function() {});
        return false;
    }
    if (p1 !== p2) {
        sweetConfirm('Passwords Mismatch', 'New password and confirm password do not match.', 'OK', function() {});
        return false;
    }
    return true;
}
</script>

<jsp:include page="includes/footer.jsp" />
