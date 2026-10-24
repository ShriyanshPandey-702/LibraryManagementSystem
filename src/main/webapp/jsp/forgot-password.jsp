<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:include page="includes/header.jsp" />

<div class="container d-flex align-items-center justify-content-center min-vh-100">
    <div class="glass-card" style="max-width: 480px; width: 100%;">
        <div class="text-center mb-4">
            <i class="fas fa-key fa-3x text-warning mb-3"></i>
            <h3 class="fw-bold">Reset Password</h3>
            <p class="text-muted">Create a new secure password</p>
        </div>

        <% String userType = (String) request.getAttribute("userType");
           if (userType == null || userType.trim().isEmpty()) {
               userType = request.getParameter("userType");
           }
           if (userType == null || (!"student".equalsIgnoreCase(userType) && !"admin".equalsIgnoreCase(userType))) {
               userType = "admin";
           }
           String errorMessage = (String) request.getAttribute("errorMessage"); %>

        <% if (errorMessage != null) { %>
            <div class="alert alert-danger shadow-sm"><i class="fas fa-exclamation-circle me-2"></i><%= errorMessage %></div>
        <% } %>

        <form action="<%= request.getContextPath() %>/ForgotPasswordServlet" method="post">
            <div class="mb-3">
                <label class="form-label fw-bold">Account Type</label>
                <div class="input-group">
                    <span class="input-group-text bg-white"><i class="fas fa-users text-muted"></i></span>
                    <select class="form-select border-start-0" name="userType" id="userTypeSelect" required onchange="updateIdentifierLabel()">
                        <option value="admin" <%= "admin".equals(userType) ? "selected" : "" %>>Admin</option>
                        <option value="student" <%= "student".equals(userType) ? "selected" : "" %>>Student</option>
                    </select>
                </div>
            </div>

            <div class="mb-3">
                <label class="form-label fw-bold" id="identifierLabel"><%= "admin".equals(userType) ? "Username" : "Email Address" %></label>
                <div class="input-group">
                    <span class="input-group-text bg-white"><i class="fas fa-id-card text-muted"></i></span>
                    <input type="text" class="form-control border-start-0" name="identifier" required>
                </div>
            </div>

            <div class="mb-3">
                <label class="form-label fw-bold">New Password</label>
                <div class="input-group">
                    <span class="input-group-text bg-white"><i class="fas fa-lock text-muted"></i></span>
                    <input type="password" class="form-control border-start-0" name="newPassword" required placeholder="********">
                </div>
            </div>

            <div class="mb-4">
                <label class="form-label fw-bold">Confirm Password</label>
                <div class="input-group">
                    <span class="input-group-text bg-white"><i class="fas fa-lock text-muted"></i></span>
                    <input type="password" class="form-control border-start-0" name="confirmPassword" required placeholder="********">
                </div>
            </div>

            <button type="submit" class="btn btn-primary-custom w-100 py-2 mb-3">Update Password</button>
        </form>

        <div class="text-center border-top pt-3">
            <a href="<%= request.getContextPath() %>/" class="text-muted text-decoration-none small"><i class="fas fa-arrow-left me-1"></i> Back to Home</a>
        </div>
    </div>
</div>

<script>
function updateIdentifierLabel() {
    var select = document.getElementById("userTypeSelect");
    var label = document.getElementById("identifierLabel");
    if (select.value === "admin") {
        label.innerText = "Username";
    } else {
        label.innerText = "Email Address";
    }
}
</script>

<jsp:include page="includes/footer.jsp" />
