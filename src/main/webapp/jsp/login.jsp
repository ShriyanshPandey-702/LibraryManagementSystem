<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:include page="includes/header.jsp" />

<div class="container d-flex align-items-center justify-content-center min-vh-100">
    <div class="glass-card" style="max-width: 450px; width: 100%;">
        <div class="text-center mb-4">
            <i class="fas fa-user-shield fa-3x text-primary mb-3"></i>
            <h3 class="fw-bold">Admin Portal</h3>
            <p class="text-muted">Login to manage the library</p>
        </div>

        <% String successMessage = (String) request.getAttribute("successMessage"); %>
        <% if (successMessage != null) { %>
            <div class="alert alert-success shadow-sm"><i class="fas fa-check-circle me-2"></i><%= successMessage %></div>
        <% } %>
        <% String errorMessage = (String) request.getAttribute("errorMessage"); %>
        <% if (errorMessage != null) { %>
            <div class="alert alert-danger shadow-sm"><i class="fas fa-exclamation-circle me-2"></i><%= errorMessage %></div>
        <% } %>

        <form action="<%= request.getContextPath() %>/LoginServlet" method="post">
            <div class="mb-3">
                <label class="form-label fw-bold">Username</label>
                <div class="input-group">
                    <span class="input-group-text bg-white"><i class="fas fa-user text-muted"></i></span>
                    <input type="text" class="form-control border-start-0" name="username" required placeholder="admin">
                </div>
            </div>

            <div class="mb-4">
                <div class="d-flex justify-content-between align-items-center">
                    <label class="form-label fw-bold mb-0">Password</label>
                    <a href="<%= request.getContextPath() %>/ForgotPasswordServlet?userType=admin" class="small text-decoration-none">Forgot Password?</a>
                </div>
                <div class="input-group mt-2">
                    <span class="input-group-text bg-white"><i class="fas fa-lock text-muted"></i></span>
                    <input type="password" class="form-control border-start-0" name="password" required placeholder="********">
                </div>
            </div>

            <button type="submit" class="btn btn-primary-custom w-100 py-2 mb-3">Login Securely</button>
        </form>

        <div class="text-center mt-3 border-top pt-3">
            <a href="<%= request.getContextPath() %>/" class="text-muted text-decoration-none small"><i class="fas fa-arrow-left me-1"></i> Back to Home</a>
        </div>
    </div>
</div>

<jsp:include page="includes/footer.jsp" />
