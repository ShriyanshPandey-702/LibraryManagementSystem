<%@ page contentType="text/html;charset=UTF-8" %>
<%
    if (session.getAttribute("adminUser") == null) {
        response.sendRedirect(request.getContextPath() + "/LoginServlet");
        return;
    }
    String successMessage = (String) request.getAttribute("successMessage");
    String errorMessage   = (String) request.getAttribute("errorMessage");
    Object finePerDay     = request.getAttribute("finePerDay");
%>
<jsp:include page="includes/header.jsp" />
<jsp:include page="includes/admin-navbar.jsp" />

<div class="page-content">

    <!-- Page Header -->
    <header class="page-header">
        <div>
            <h1 class="page-title">Fine Settings</h1>
            <p class="page-subtitle">Configure the institutional daily penalty rate applied to overdue book returns.</p>
        </div>
        <div class="page-header-actions">
            <a href="<%= request.getContextPath() %>/DashboardServlet" class="btn-lib-secondary">
                <i class="fas fa-arrow-left me-1"></i> Back to Dashboard
            </a>
        </div>
    </header>

    <!-- Alerts -->
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

    <!-- Rate Form Panel -->
    <div class="panel" style="max-width: 620px;">
        <div class="panel-header">
            <h2 class="panel-title">Daily Overdue Penalty Rate</h2>
        </div>
        <div class="panel-body">
            <form action="<%= request.getContextPath() %>/FineSettingsServlet" method="post">
                <div class="mb-4">
                    <label for="finePerDayInput" class="form-label">Penalty Amount Per Day (₹) <span class="text-danger">*</span></label>
                    <div class="input-group" style="max-width: 240px;">
                        <span class="input-group-text">₹</span>
                        <input type="number" id="finePerDayInput" step="0.01" min="0" class="form-control" name="finePerDay"
                               value="<%= finePerDay != null ? finePerDay : "5.00" %>" required>
                    </div>
                    <div class="form-text mt-2">
                        Applied across all active book loans for each calendar day elapsed beyond the due date.
                    </div>
                </div>

                <div class="pt-3 border-top d-flex gap-2">
                    <button type="submit" class="btn-lib-primary px-4">
                        <i class="fas fa-check me-1"></i> Save Rate Changes
                    </button>
                    <a href="<%= request.getContextPath() %>/SettingsServlet" class="btn-lib-secondary">
                        Cancel
                    </a>
                </div>
            </form>
        </div>
    </div>

    <!-- Calculation Policy Panel -->
    <div class="panel" style="max-width: 620px;">
        <div class="panel-header">
            <h3 class="panel-title h6">Fine Calculation Rules</h3>
        </div>
        <div class="panel-body text-secondary small">
            <ul class="mb-0 ps-3">
                <li class="mb-1"><strong>Daily Rate Formula:</strong> Total Fine = Daily Rate × Days Past Due.</li>
                <li class="mb-1"><strong>Grace Period:</strong> Fines begin accruing immediately on the calendar day following the due date.</li>
                <li class="mb-1"><strong>Settlement:</strong> Outstanding balances are itemized in the student portal and can be cleared prior to new loans.</li>
                <li><strong>Return Check-in:</strong> Unsettled fines remain linked to the student's circulation account until recorded as paid.</li>
            </ul>
        </div>
    </div>

</div><!-- /.page-content -->

<jsp:include page="includes/admin-footer.jsp" />
<jsp:include page="includes/footer.jsp" />
