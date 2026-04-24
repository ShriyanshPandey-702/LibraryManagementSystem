<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.Student" %>
<%
    Student student = (Student) session.getAttribute("studentUser");
    if (student == null) {
        response.sendRedirect(request.getContextPath() + "/jsp/student-login.jsp");
        return;
    }
%>
<jsp:include page="includes/header.jsp" />
<jsp:include page="includes/student-navbar.jsp" />

<div class="main-content bg-light">
    <div class="container py-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h3 class="fw-bold"><i class="fas fa-user-circle me-2 text-primary"></i>My Profile</h3>
            <a href="<%= request.getContextPath() %>/StudentDashboardServlet" class="btn btn-outline-secondary"><i class="fas fa-arrow-left me-1"></i>Back</a>
        </div>

        <% String successMessage = (String) request.getAttribute("successMessage"); %>
        <% String errorMessage = (String) request.getAttribute("errorMessage"); %>
        <% if (successMessage != null) { %>
            <div class="alert alert-success shadow-sm"><i class="fas fa-check-circle me-2"></i><%= successMessage %></div>
        <% } %>
        <% if (errorMessage != null) { %>
            <div class="alert alert-danger shadow-sm"><i class="fas fa-exclamation-circle me-2"></i><%= errorMessage %></div>
        <% } %>

        <div class="row g-4">
            <div class="col-md-4">
                <div class="glass-card text-center p-4">
                    <div class="mb-3">
                        <div class="bg-primary text-white rounded-circle d-inline-flex align-items-center justify-content-center shadow" style="width: 100px; height: 100px; font-size: 40px;">
                            <%= student.getName().substring(0, 1).toUpperCase() %>
                        </div>
                    </div>
                    <h4 class="fw-bold mb-1"><%= student.getName() %></h4>
                    <p class="text-muted"><%= student.getEmail() %></p>
                    <hr>
                    <div class="text-start">
                        <p class="mb-2"><strong>Member Since:</strong> 2026</p>
                        <p class="mb-2"><strong>Status:</strong> <span class="badge bg-success">Active</span></p>
                    </div>
                </div>
            </div>

            <div class="col-md-8">
                <div class="glass-card p-4 mb-4">
                    <h5 class="fw-bold mb-4"><i class="fas fa-info-circle me-2 text-info"></i>Personal Information</h5>
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label text-muted small fw-bold">Full Name</label>
                            <p class="border-bottom pb-2 fs-5"><%= student.getName() %></p>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label text-muted small fw-bold">Email Address</label>
                            <p class="border-bottom pb-2 fs-5"><%= student.getEmail() %></p>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label text-muted small fw-bold">Mobile Number</label>
                            <p class="border-bottom pb-2 fs-5"><%= student.getMobile() != null ? student.getMobile() : "N/A" %></p>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label text-muted small fw-bold">Course & Year</label>
                            <p class="border-bottom pb-2 fs-5"><%= student.getCourse() %> (<%= student.getYear() %> Year)</p>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label text-muted small fw-bold">Section</label>
                            <p class="border-bottom pb-2 fs-5"><%= student.getSection() != null ? student.getSection() : "A" %></p>
                        </div>
                        <div class="col-md-12">
                            <label class="form-label text-muted small fw-bold">Address</label>
                            <p class="border-bottom pb-2 fs-5"><%= student.getAddress() != null ? student.getAddress() : "N/A" %></p>
                        </div>
                    </div>
                </div>

                <div class="glass-card p-4">
                    <h5 class="fw-bold mb-4"><i class="fas fa-lock me-2 text-warning"></i>Security Settings</h5>
                    <form action="<%= request.getContextPath() %>/StudentProfileServlet" method="post" class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label fw-bold">New Password</label>
                            <input type="password" name="newPassword" class="form-control" placeholder="Leave blank to keep current">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-bold">Confirm New Password</label>
                            <input type="password" name="confirmPassword" class="form-control" placeholder="Confirm your new password">
                        </div>
                        <div class="col-12 mt-3">
                            <button type="submit" class="btn btn-warning fw-bold px-4 shadow-sm">Update Security Info</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="includes/footer.jsp" />
