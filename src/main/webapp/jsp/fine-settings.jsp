<%@ page contentType="text/html;charset=UTF-8" %>
<%
    if (session.getAttribute("adminUser") == null) {
        response.sendRedirect(request.getContextPath() + "/LoginServlet");
        return;
    }
    String successMessage    = (String) request.getAttribute("successMessage");
    String errorMessage      = (String) request.getAttribute("errorMessage");
    Object finePerDay        = request.getAttribute("finePerDay");
    Object renewalDays       = request.getAttribute("renewalDays");
    Object maxBooksPerStudent = request.getAttribute("maxBooksPerStudent");
    Object pickupDays        = request.getAttribute("pickupDays");
%>
<jsp:include page="includes/header.jsp" />
<jsp:include page="includes/admin-navbar.jsp" />

<div class="page-content">

    <!-- Page Header -->
    <header class="page-header">
        <div>
            <h1 class="page-title">Library Policies & Settings</h1>
            <p class="page-subtitle">Configure institutional rules for borrowing quotas, loan renewal extensions, pickup deadlines, and fine rates.</p>
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

    <div class="row g-4">
        <div class="col-lg-7">
            <!-- Policy Form Panel -->
            <div class="panel">
                <div class="panel-header">
                    <h2 class="panel-title">Institutional Circulation Rules</h2>
                </div>
                <div class="panel-body">
                    <form action="<%= request.getContextPath() %>/FineSettingsServlet" method="post">
                        
                        <!-- Daily Fine Rate -->
                        <div class="mb-4">
                            <label for="finePerDayInput" class="form-label fw-bold">Overdue Penalty Per Day (₹) <span class="text-danger">*</span></label>
                            <div class="input-group" style="max-width: 260px;">
                                <span class="input-group-text">₹</span>
                                <input type="number" id="finePerDayInput" step="0.50" min="0" class="form-control" name="finePerDay"
                                       value="<%= finePerDay != null ? finePerDay : "5.00" %>" required>
                            </div>
                            <div class="form-text mt-1">
                                Applied across active book loans for each calendar day past the due date.
                            </div>
                        </div>

                        <!-- Renewal Extension Days -->
                        <div class="mb-4">
                            <label for="renewalDaysInput" class="form-label fw-bold">Loan Renewal Extension (Days) <span class="text-danger">*</span></label>
                            <div class="input-group" style="max-width: 260px;">
                                <input type="number" id="renewalDaysInput" step="1" min="1" max="60" class="form-control" name="renewalDays"
                                       value="<%= renewalDays != null ? renewalDays : "7" %>" required>
                                <span class="input-group-text">Days</span>
                            </div>
                            <div class="form-text mt-1">
                                Calendar days added to the due date when a student self-renews an active loan.
                            </div>
                        </div>

                        <!-- Maximum Borrowing Quota -->
                        <div class="mb-4">
                            <label for="maxBooksInput" class="form-label fw-bold">Maximum Active Books Per Student <span class="text-danger">*</span></label>
                            <div class="input-group" style="max-width: 260px;">
                                <input type="number" id="maxBooksInput" step="1" min="1" max="50" class="form-control" name="maxBooksPerStudent"
                                       value="<%= maxBooksPerStudent != null ? maxBooksPerStudent : "3" %>" required>
                                <span class="input-group-text">Books</span>
                            </div>
                            <div class="form-text mt-1">
                                Strict borrowing quota enforced across book requests and manual admin checkouts.
                            </div>
                        </div>

                        <!-- Reservation Pickup Deadline -->
                        <div class="mb-4">
                            <label for="pickupDaysInput" class="form-label fw-bold">Reservation Pickup Window (Days) <span class="text-danger">*</span></label>
                            <div class="input-group" style="max-width: 260px;">
                                <input type="number" id="pickupDaysInput" step="1" min="1" max="30" class="form-control" name="pickupDays"
                                       value="<%= pickupDays != null ? pickupDays : "3" %>" required>
                                <span class="input-group-text">Days</span>
                            </div>
                            <div class="form-text mt-1">
                                Time window a student has to collect a reserved copy before it is passed to the next in queue.
                            </div>
                        </div>

                        <div class="pt-3 border-top d-flex gap-2">
                            <button type="submit" class="btn-lib-primary px-4">
                                <i class="fas fa-check me-1"></i> Save Policy Settings
                            </button>
                            <a href="<%= request.getContextPath() %>/DashboardServlet" class="btn-lib-secondary">
                                Cancel
                            </a>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <div class="col-lg-5">
            <!-- Rules Reference Panel -->
            <div class="panel">
                <div class="panel-header">
                    <h3 class="panel-title h6">Policy Specifications</h3>
                </div>
                <div class="panel-body text-secondary small">
                    <ul class="mb-0 ps-3">
                        <li class="mb-2"><strong>Dynamic Fine Calculation:</strong> Fines accrue daily from the day following the scheduled due date until physical check-in.</li>
                        <li class="mb-2"><strong>Renewal Safeguards:</strong> A maximum of 2 extensions are permitted per loan. Overdue loans with outstanding fines cannot be renewed until returned.</li>
                        <li class="mb-2"><strong>Quota Protection:</strong> Students who reach the maximum book limit cannot place reservation requests or borrow additional volumes.</li>
                        <li class="mb-2"><strong>FIFO Reservation Queue:</strong> When a copy is returned, it is automatically allocated to the earliest waiting reservation with notification dispatched.</li>
                        <li><strong>Audit Ledger:</strong> All settlements and fine overrides are itemized with timestamped records.</li>
                    </ul>
                </div>
            </div>
        </div>
    </div>

</div><!-- /.page-content -->

<jsp:include page="includes/admin-footer.jsp" />
<jsp:include page="includes/footer.jsp" />
