<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:include page="includes/header.jsp" />

<div class="auth-split-container">
    <div class="auth-split-card wide-form">
        <!-- Visual Artwork Panel (Left Pane) -->
        <div class="auth-split-visual">
            <img src="<%= request.getContextPath() %>/images/student-login-art.png" alt="Student Academic Registration" class="auth-split-visual-img">
            <div class="auth-split-visual-overlay"></div>
            
            <div class="auth-split-visual-top">
                <span class="auth-visual-pill">
                    <i class="fas fa-id-card me-1"></i> Student Onboarding
                </span>
                <span class="auth-visual-pill">
                    <i class="fas fa-book-reader me-1"></i> Academic Hub
                </span>
            </div>

            <div class="auth-split-visual-bottom">
                <div class="auth-visual-author-card">
                    <div class="d-flex align-items-center gap-3">
                        <div class="auth-author-avatar">
                            <i class="fas fa-user-plus"></i>
                        </div>
                        <div>
                            <div class="auth-author-title">Join Libris Portal</div>
                            <div class="auth-author-sub">Borrow Books & Access Catalog</div>
                        </div>
                    </div>
                    <div class="auth-visual-status">
                        <span class="status-dot"></span> Active
                    </div>
                </div>
            </div>
        </div>

        <!-- Form Panel (Right Pane) -->
        <div class="auth-split-form">
            <div class="auth-split-header">
                <a href="<%= request.getContextPath() %>/" class="auth-split-brand">
                    <i class="fas fa-book-journal-whills me-2" style="color: var(--color-primary);"></i>libris<span style="color: var(--color-accent);">.</span>
                </a>
                <a href="<%= request.getContextPath() %>/StudentLoginServlet" class="auth-portal-badge" title="Already have an account? Sign In">
                    <span>Student Login</span>
                    <i class="fas fa-arrow-right ms-1"></i>
                </a>
            </div>

            <div class="auth-form-content">
                <h1 class="auth-split-title">Student Registration</h1>
                <p class="auth-split-subtitle">Register your academic library account to borrow books and submit requests</p>

                <% String errorMessage = (String) request.getAttribute("errorMessage"); %>
                <% if (errorMessage != null && !errorMessage.isEmpty()) { %>
                    <div class="alert alert-danger mb-3" role="alert">
                        <i class="fas fa-circle-exclamation me-2"></i><%= errorMessage %>
                    </div>
                <% } %>

                <form action="<%= request.getContextPath() %>/StudentRegisterServlet" method="post">
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label for="regName" class="auth-input-label">Full Name</label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="fas fa-user"></i></span>
                                <input type="text" id="regName" name="name" class="form-control" required placeholder="e.g. Alex Morgan">
                            </div>
                        </div>
                        <div class="col-md-6">
                            <label for="regEmail" class="auth-input-label">Email Address</label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="fas fa-envelope"></i></span>
                                <input type="email" id="regEmail" name="email" class="form-control" required placeholder="student@example.edu" autocomplete="email">
                            </div>
                        </div>
                        <div class="col-md-6">
                            <label for="regMobile" class="auth-input-label">Mobile Number</label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="fas fa-phone"></i></span>
                                <input type="tel" id="regMobile" name="mobile" class="form-control" required placeholder="10-digit mobile number">
                            </div>
                        </div>
                        <div class="col-md-6">
                            <label for="regPassword" class="auth-input-label">Account Password</label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="fas fa-lock"></i></span>
                                <input type="password" id="regPassword" name="password" class="form-control" required placeholder="Minimum 6 characters" autocomplete="new-password">
                            </div>
                        </div>
                        <div class="col-md-4">
                            <label for="regCourse" class="auth-input-label">Course / Degree</label>
                            <input type="text" id="regCourse" name="course" class="form-control" required placeholder="e.g. B.Tech Computer Science">
                        </div>
                        <div class="col-md-4">
                            <label for="regYear" class="auth-input-label">Academic Year</label>
                            <select id="regYear" name="year" class="form-select" required>
                                <option value="1st">1st Year</option>
                                <option value="2nd" selected>2nd Year</option>
                                <option value="3rd">3rd Year</option>
                                <option value="4th">4th Year</option>
                            </select>
                        </div>
                        <div class="col-md-4">
                            <label for="regSection" class="auth-input-label">Section</label>
                            <input type="text" id="regSection" name="section" class="form-control" required placeholder="e.g. A">
                        </div>
                        <div class="col-md-12">
                            <label for="regAddress" class="auth-input-label">Residential Address</label>
                            <textarea id="regAddress" name="address" class="form-control" rows="2" required placeholder="Hostel block or residential mailing address"></textarea>
                        </div>
                    </div>

                    <div class="mt-4">
                        <button type="submit" class="auth-submit-btn">
                            <i class="fas fa-id-card me-2"></i> Register Student Account
                        </button>
                    </div>
                </form>
            </div>

            <div class="auth-split-footer">
                <p class="mb-2">Already registered? <a href="<%= request.getContextPath() %>/StudentLoginServlet" class="fw-bold">Sign in here</a></p>
                <a href="<%= request.getContextPath() %>/" class="auth-return-link">
                    <i class="fas fa-arrow-left me-1"></i> Return to Homepage
                </a>
            </div>
        </div>
    </div>
</div>

<jsp:include page="includes/footer.jsp" />
