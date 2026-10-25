<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.Student" %>
<%
    Student student = (Student) session.getAttribute("studentUser");
    if (student == null) {
        response.sendRedirect(request.getContextPath() + "/StudentLoginServlet");
        return;
    }
    String initial = student.getName() != null && !student.getName().isEmpty()
        ? student.getName().substring(0, 1).toUpperCase() : "S";
%>
<jsp:include page="includes/header.jsp" />
<jsp:include page="includes/student-navbar.jsp" />

<main class="page-content py-4">

    <!-- Page Header -->
    <header class="page-header">
        <div>
            <h1 class="page-title">Profile &amp; Security</h1>
            <p class="page-subtitle">Inspect registered institutional records and update your account password.</p>
        </div>
        <div class="page-header-actions">
            <a href="<%= request.getContextPath() %>/StudentDashboardServlet" class="btn-lib-secondary">
                <i class="fas fa-arrow-left me-1"></i> Dashboard
            </a>
        </div>
    </header>

    <% String successMessage = (String) request.getAttribute("successMessage"); %>
    <% String errorMessage = (String) request.getAttribute("errorMessage"); %>
    <% if (successMessage != null && !successMessage.isEmpty()) { %>
        <div class="alert alert-success mb-4" role="alert">
            <i class="fas fa-check-circle me-2"></i><%= successMessage %>
        </div>
    <% } %>
    <% if (errorMessage != null && !errorMessage.isEmpty()) { %>
        <div class="alert alert-danger mb-4" role="alert">
            <i class="fas fa-circle-exclamation me-2"></i><%= errorMessage %>
        </div>
    <% } %>

    <div class="row g-4">
        <!-- Student Identity Summary Card -->
        <div class="col-lg-4">
            <div class="panel text-center">
                <div class="panel-body py-4">
                    <div class="mb-3">
                        <div class="d-inline-flex align-items-center justify-content-center bg-dark text-white rounded-1 fw-bold border"
                             style="width: 72px; height: 72px; font-size: 2rem;">
                            <%= initial %>
                        </div>
                    </div>
                    <h2 class="h5 fw-bold mb-1"><%= student.getName() %></h2>
                    <p class="text-muted small mb-3"><%= student.getEmail() %></p>

                    <div class="border-top pt-3 text-start small">
                        <div class="d-flex justify-content-between py-2 border-bottom">
                            <span class="text-muted">Membership ID:</span>
                            <span class="fw-bold font-monospace">#STUD-<%= student.getId() %></span>
                        </div>
                        <div class="d-flex justify-content-between py-2 border-bottom">
                            <span class="text-muted">Account Status:</span>
                            <span class="badge-status badge-success">Active Member</span>
                        </div>
                        <div class="d-flex justify-content-between py-2 border-bottom">
                            <span class="text-muted">Course:</span>
                            <span class="fw-semibold"><%= student.getCourse() != null ? student.getCourse() : "N/A" %></span>
                        </div>
                        <div class="d-flex justify-content-between py-2">
                            <span class="text-muted">Academic Year:</span>
                            <span class="fw-semibold"><%= student.getYear() != null ? student.getYear() : "N/A" %> Year</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Academic Details & Security Forms -->
        <div class="col-lg-8">
            <!-- Academic Record Panel -->
            <div class="panel mb-4">
                <div class="panel-header">
                    <h2 class="panel-title">Institutional Registration Details</h2>
                    <span class="badge-status badge-neutral">Institutional Record</span>
                </div>
                <div class="panel-body">
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label text-muted small fw-bold">Full Legal Name</label>
                            <div class="form-control bg-light py-2"><%= student.getName() %></div>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label text-muted small fw-bold">Institutional Email</label>
                            <div class="form-control bg-light py-2"><%= student.getEmail() %></div>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label text-muted small fw-bold">Contact Phone Number</label>
                            <div class="form-control bg-light py-2"><%= student.getMobile() != null && !student.getMobile().isBlank() ? student.getMobile() : "Not provided" %></div>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label text-muted small fw-bold">Course / Degree Program</label>
                            <div class="form-control bg-light py-2"><%= student.getCourse() != null ? student.getCourse() : "N/A" %> (<%= student.getYear() != null ? student.getYear() : "" %> Year)</div>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label text-muted small fw-bold">Assigned Class Section</label>
                            <div class="form-control bg-light py-2"><%= student.getSection() != null ? student.getSection() : "A" %></div>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label text-muted small fw-bold">Residential Mailing Address</label>
                            <div class="form-control bg-light py-2"><%= student.getAddress() != null && !student.getAddress().isBlank() ? student.getAddress() : "N/A" %></div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Password Update Panel -->
            <div class="panel">
                <div class="panel-header">
                    <h2 class="panel-title">Update Password</h2>
                </div>
                <div class="panel-body">
                    <form action="<%= request.getContextPath() %>/StudentProfileServlet" method="post" onsubmit="return validatePasswordForm();">
                        <div class="row g-3">
                            <div class="col-md-6">
                                <label for="newPassword" class="form-label">New Password <span class="text-danger">*</span></label>
                                <div class="input-group">
                                    <span class="input-group-text"><i class="fas fa-lock"></i></span>
                                    <input type="password" id="newPassword" name="newPassword" class="form-control" required placeholder="Minimum 6 characters" autocomplete="new-password">
                                </div>
                            </div>
                            <div class="col-md-6">
                                <label for="confirmPassword" class="form-label">Confirm New Password <span class="text-danger">*</span></label>
                                <div class="input-group">
                                    <span class="input-group-text"><i class="fas fa-shield-check"></i></span>
                                    <input type="password" id="confirmPassword" name="confirmPassword" class="form-control" required placeholder="Re-type new password" autocomplete="new-password">
                                </div>
                            </div>
                        </div>

                        <div class="mt-4 pt-3 border-top">
                            <button type="submit" class="btn-lib-primary px-4">
                                <i class="fas fa-check me-1"></i> Update Account Password
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>

</main>

<footer class="site-footer">
    <div class="container-xl d-flex justify-content-between align-items-center flex-wrap gap-2">
        <span>&copy; Library Management System &bull; Academic Operations Platform</span>
        <span class="text-muted small">Student Profile</span>
    </div>
</footer>

<script>
function validatePasswordForm() {
    const p1 = document.getElementById('newPassword').value;
    const p2 = document.getElementById('confirmPassword').value;
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
