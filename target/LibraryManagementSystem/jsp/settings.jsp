<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    if (session.getAttribute("adminUser") == null) {
        response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
        return;
    }
%>
<jsp:include page="includes/header.jsp" />
<jsp:include page="includes/admin-navbar.jsp" />

<div class="main-content bg-light">
    <div class="container py-4">
        <div class="mb-4">
            <h3 class="fw-bold"><i class="fas fa-cog me-2 text-secondary"></i>System Settings</h3>
            <p class="text-muted">Manage library rules and administrative configurations.</p>
        </div>

        <div class="row g-4">
            <div class="col-md-4">
                <a href="<%= request.getContextPath() %>/FineSettingsServlet" class="text-decoration-none">
                    <div class="card h-100 shadow-sm border-0 glass-card text-center p-4">
                        <div class="icon-wrapper bg-warning-subtle text-warning mb-3 mx-auto" style="width: 70px; height: 70px; border-radius: 50%; display: flex; align-items: center; justify-content: center;">
                            <i class="fas fa-coins fa-2x"></i>
                        </div>
                        <h5 class="fw-bold text-dark">Fine Settings</h5>
                        <p class="text-muted small">Update fine rates per day for overdue book returns.</p>
                        <span class="btn btn-sm btn-outline-warning mt-2">Configure</span>
                    </div>
                </a>
            </div>

            <div class="col-md-4">
                <div class="card h-100 shadow-sm border-0 glass-card text-center p-4 opacity-75">
                    <div class="icon-wrapper bg-info-subtle text-info mb-3 mx-auto" style="width: 70px; height: 70px; border-radius: 50%; display: flex; align-items: center; justify-content: center;">
                        <i class="fas fa-laptop-code fa-2x"></i>
                    </div>
                    <h5 class="fw-bold text-dark">System Settings</h5>
                    <p class="text-muted small">Library name, contact details, and general preferences.</p>
                    <span class="badge bg-secondary mt-2">Coming Soon</span>
                </div>
            </div>

            <div class="col-md-4">
                <div class="card h-100 shadow-sm border-0 glass-card text-center p-4 opacity-75">
                    <div class="icon-wrapper bg-primary-subtle text-primary mb-3 mx-auto" style="width: 70px; height: 70px; border-radius: 50%; display: flex; align-items: center; justify-content: center;">
                        <i class="fas fa-user-shield fa-2x"></i>
                    </div>
                    <h5 class="fw-bold text-dark">Account Settings</h5>
                    <p class="text-muted small">Change admin password and profile security settings.</p>
                    <span class="badge bg-secondary mt-2">Coming Soon</span>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="includes/footer.jsp" />
