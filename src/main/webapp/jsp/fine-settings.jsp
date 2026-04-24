<%@ page contentType="text/html;charset=UTF-8" %>
<jsp:include page="includes/header.jsp" />
<jsp:include page="includes/admin-navbar.jsp" />

<div class="main-content bg-light">
    <div class="container py-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h3 class="fw-bold"><i class="fas fa-coins me-2 text-warning"></i>Fine Settings</h3>
            <a href="<%= request.getContextPath() %>/SettingsServlet" class="btn btn-outline-secondary"><i class="fas fa-arrow-left me-1"></i>Back to Settings</a>
        </div>

        <% String successMessage = (String) request.getAttribute("successMessage"); %>
        <% String errorMessage = (String) request.getAttribute("errorMessage"); %>
        <% if (successMessage != null) { %>
            <div class="alert alert-success shadow-sm"><i class="fas fa-check-circle me-2"></i><%= successMessage %></div>
        <% } %>
        <% if (errorMessage != null) { %>
            <div class="alert alert-danger shadow-sm"><i class="fas fa-exclamation-circle me-2"></i><%= errorMessage %></div>
        <% } %>

        <div class="glass-card" style="max-width: 500px;">
            <form action="<%= request.getContextPath() %>/FineSettingsServlet" method="post">
                <div class="mb-4">
                    <label class="form-label fw-bold">Fine Per Day (₹)</label>
                    <div class="input-group">
                        <span class="input-group-text bg-white border-end-0">₹</span>
                        <input type="number" step="0.01" min="0" class="form-control border-start-0" name="finePerDay"
                               value="<%= request.getAttribute("finePerDay") != null ? request.getAttribute("finePerDay") : "0.00" %>" required>
                    </div>
                    <div class="form-text mt-2">This amount will be charged daily for each overdue book.</div>
                </div>
                <div class="d-grid">
                    <button type="submit" class="btn btn-warning fw-bold"><i class="fas fa-save me-1"></i> Update Fine Rate</button>
                </div>
            </form>
        </div>
    </div>
</div>

<jsp:include page="includes/footer.jsp" />

