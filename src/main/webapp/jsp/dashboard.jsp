<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    if (session.getAttribute("adminUser") == null) {
        response.sendRedirect(request.getContextPath() + "/LoginServlet");
        return;
    }
    Object totalBooks    = request.getAttribute("totalBooks");
    Object totalQty      = request.getAttribute("totalQuantity");
    Object lowStock      = request.getAttribute("lowStock");
    Object totalStudents = request.getAttribute("totalStudents");
    Object totalIssued   = request.getAttribute("totalIssued");
    Integer pendingReqs  = (Integer) request.getAttribute("pendingRequests");
    int pendingCount     = pendingReqs == null ? 0 : pendingReqs;
    String adminName     = session.getAttribute("adminUser") != null ? session.getAttribute("adminUser").toString() : "Admin";
%>
<jsp:include page="includes/header.jsp" />
<jsp:include page="includes/admin-navbar.jsp" />

<div class="page-content">

    <!-- Page Header -->
    <header class="page-header">
        <div>
            <h1 class="page-title">Library Overview</h1>
            <p class="page-subtitle">Welcome back, <%= adminName %>. Real-time circulation status and catalog metrics.</p>
        </div>
        <div class="page-header-actions d-flex flex-wrap gap-2">
            <div class="btn-group">
                <button type="button" class="btn-lib-secondary dropdown-toggle" data-bs-toggle="dropdown" aria-expanded="false">
                    <i class="fas fa-file-csv text-success me-1"></i> Export Data (CSV)
                </button>
                <ul class="dropdown-menu dropdown-menu-end" style="background-color: var(--color-surface); border: 1px solid var(--color-border);">
                    <li><a class="dropdown-item small" href="<%= request.getContextPath() %>/ExportBooksServlet"><i class="fas fa-book me-2"></i>Export Catalog</a></li>
                    <li><a class="dropdown-item small" href="<%= request.getContextPath() %>/ExportLoansServlet"><i class="fas fa-arrow-right-arrow-left me-2"></i>Export Circulation Loans</a></li>
                    <li><a class="dropdown-item small" href="<%= request.getContextPath() %>/ExportFinesServlet"><i class="fas fa-receipt me-2"></i>Export Fines &amp; Settlements</a></li>
                </ul>
            </div>
            <a href="<%= request.getContextPath() %>/AddBookServlet" class="btn-lib-primary">
                <i class="fas fa-plus"></i> Add New Book
            </a>
        </div>
    </header>

    <% if (pendingCount > 0) { %>
    <!-- Actionable Alert for Pending Requests -->
    <div class="alert alert-warning d-flex justify-content-between align-items-center mb-4" role="alert">
        <div>
            <i class="fas fa-bell me-2"></i>
            There <%= pendingCount == 1 ? "is" : "are" %> <strong><%= pendingCount %> pending student book request<%= pendingCount > 1 ? "s" : "" %></strong> awaiting librarian review.
        </div>
        <a href="<%= request.getContextPath() %>/AdminBookRequestsServlet" class="btn-lib-primary btn-sm">
            Review Requests <i class="fas fa-arrow-right ms-1"></i>
        </a>
    </div>
    <% } %>

    <%
        Object overdueCount = request.getAttribute("overdueCount");
        Object outstandingFines = request.getAttribute("outstandingFines");
        Object pendingReservations = request.getAttribute("pendingReservations");
        Object pendingReports = request.getAttribute("pendingReports");
        Double avgRating = (Double) request.getAttribute("catalogAvgRating");
        int totalCopies = totalQty != null ? Integer.parseInt(totalQty.toString()) : 0;
        int activeLoans = totalIssued != null ? Integer.parseInt(totalIssued.toString()) : 0;
        int availCopies = Math.max(0, totalCopies - activeLoans);
    %>

    <!-- Real Metrics Grid -->
    <div class="row g-3 mb-4">
        <div class="col-sm-6 col-xl-3">
            <div class="metric-card">
                <div class="metric-label">// 01 CATALOG TITLES</div>
                <div class="metric-value"><%= totalBooks != null ? totalBooks : "0" %></div>
                <div class="metric-sub"><i class="fas fa-book me-1"></i> Unique book titles</div>
            </div>
        </div>
        <div class="col-sm-6 col-xl-3">
            <div class="metric-card">
                <div class="metric-label">// 02 PHYSICAL COPIES</div>
                <div class="metric-value"><%= totalCopies %></div>
                <div class="metric-sub"><span class="text-success"><%= availCopies %> Available</span> &bull; <%= activeLoans %> Borrowed</div>
            </div>
        </div>
        <div class="col-sm-6 col-xl-3">
            <div class="metric-card">
                <div class="metric-label">// 03 ACTIVE LOANS</div>
                <div class="metric-value"><%= activeLoans %></div>
                <div class="metric-sub"><i class="fas fa-arrow-right-arrow-left me-1"></i> Total active student loans</div>
            </div>
        </div>
        <div class="col-sm-6 col-xl-3">
            <div class="metric-card">
                <div class="metric-label">// 04 REGISTERED STUDENTS</div>
                <div class="metric-value"><%= totalStudents != null ? totalStudents : "0" %></div>
                <div class="metric-sub"><i class="fas fa-user-graduate me-1"></i> Authorized borrowers</div>
            </div>
        </div>

        <div class="col-sm-6 col-xl-3">
            <div class="metric-card">
                <div class="metric-label">// 05 OVERDUE LOANS</div>
                <div class="metric-value <%= overdueCount != null && Integer.parseInt(overdueCount.toString()) > 0 ? "text-danger" : "" %>">
                    <%= overdueCount != null ? overdueCount : "0" %>
                </div>
                <div class="metric-sub"><i class="fas fa-clock me-1 text-danger"></i> Past scheduled due date</div>
            </div>
        </div>
        <div class="col-sm-6 col-xl-3">
            <div class="metric-card">
                <div class="metric-label">// 06 UNPAID FINES</div>
                <div class="metric-value <%= outstandingFines != null && ((Double)outstandingFines) > 0 ? "text-danger" : "" %>">
                    ₹<%= String.format("%.2f", outstandingFines != null ? (Double)outstandingFines : 0.0) %>
                </div>
                <div class="metric-sub"><i class="fas fa-receipt me-1 text-danger"></i> Outstanding penalty balance</div>
            </div>
        </div>
        <div class="col-sm-6 col-xl-3">
            <div class="metric-card">
                <div class="metric-label">// 07 PENDING RESERVATIONS</div>
                <div class="metric-value"><%= pendingReservations != null ? pendingReservations : "0" %></div>
                <div class="metric-sub"><i class="fas fa-calendar-check me-1"></i> Waitlist queue entries</div>
            </div>
        </div>
        <div class="col-sm-6 col-xl-3">
            <div class="metric-card">
                <div class="metric-label">// 08 REVIEWS &amp; INCIDENTS</div>
                <div class="metric-value">
                    ★ <%= String.format("%.1f", avgRating != null ? avgRating : 0.0) %>
                </div>
                <div class="metric-sub"><%= pendingReports != null ? pendingReports : "0" %> lost/damaged incidents</div>
            </div>
        </div>
    </div>

    <!-- Charts Section -->
    <%
        java.util.Map<String, Integer> catDist = (java.util.Map<String, Integer>) request.getAttribute("categoryDistribution");
        java.util.Map<String, Integer> trends = (java.util.Map<String, Integer>) request.getAttribute("borrowingTrends");
    %>
    <div class="row g-4 mb-4">
        <div class="col-lg-7">
            <div class="panel h-100 mb-0">
                <div class="panel-header">
                    <h2 class="panel-title">Borrowing Activity Trends</h2>
                    <span class="badge-status badge-neutral">Past 7 Days</span>
                </div>
                <div class="panel-body">
                    <div style="position:relative; height: 260px;">
                        <canvas id="trendChart"></canvas>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-lg-5">
            <div class="panel h-100 mb-0">
                <div class="panel-header">
                    <h2 class="panel-title">Collection by Category</h2>
                    <span class="badge-status badge-neutral">Distribution</span>
                </div>
                <div class="panel-body">
                    <div style="position:relative; height: 260px; display:flex; align-items:center; justify-content:center;">
                        <canvas id="categoryChart"></canvas>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Quick Navigation Panel -->
    <div class="panel">
        <div class="panel-header">
            <h2 class="panel-title">Frequent Operational Tasks</h2>
        </div>
        <div class="panel-body">
            <div class="row g-3">
                <div class="col-6 col-md-4 col-xl-2">
                    <a href="<%= request.getContextPath() %>/ViewBooksServlet" class="btn-lib-secondary w-100 d-flex flex-column align-items-center py-3 text-center gap-2">
                        <i class="fas fa-book fa-lg text-primary"></i>
                        <span class="small fw-semibold">View Catalog</span>
                    </a>
                </div>
                <div class="col-6 col-md-4 col-xl-2">
                    <a href="<%= request.getContextPath() %>/AddBookServlet" class="btn-lib-secondary w-100 d-flex flex-column align-items-center py-3 text-center gap-2">
                        <i class="fas fa-plus fa-lg text-primary"></i>
                        <span class="small fw-semibold">Add Book</span>
                    </a>
                </div>
                <div class="col-6 col-md-4 col-xl-2">
                    <a href="<%= request.getContextPath() %>/IssueBookServlet" class="btn-lib-secondary w-100 d-flex flex-column align-items-center py-3 text-center gap-2">
                        <i class="fas fa-arrow-right-arrow-left fa-lg text-warning"></i>
                        <span class="small fw-semibold">Issue Book</span>
                    </a>
                </div>
                <div class="col-6 col-md-4 col-xl-2">
                    <a href="<%= request.getContextPath() %>/ReturnBookServlet" class="btn-lib-secondary w-100 d-flex flex-column align-items-center py-3 text-center gap-2">
                        <i class="fas fa-rotate-left fa-lg text-info"></i>
                        <span class="small fw-semibold">Return Book</span>
                    </a>
                </div>
                <div class="col-6 col-md-4 col-xl-2">
                    <a href="<%= request.getContextPath() %>/AdminBookRequestsServlet" class="btn-lib-secondary w-100 d-flex flex-column align-items-center py-3 text-center gap-2 position-relative">
                        <i class="fas fa-inbox fa-lg text-danger"></i>
                        <span class="small fw-semibold">Book Requests</span>
                        <% if (pendingCount > 0) { %>
                            <span class="badge-status badge-danger position-absolute top-0 end-0 mt-2 me-2" style="font-size:10px;"><%= pendingCount %></span>
                        <% } %>
                    </a>
                </div>
                <div class="col-6 col-md-4 col-xl-2">
                    <a href="<%= request.getContextPath() %>/FineSettingsServlet" class="btn-lib-secondary w-100 d-flex flex-column align-items-center py-3 text-center gap-2">
                        <i class="fas fa-receipt fa-lg" style="color:var(--color-warning);"></i>
                        <span class="small fw-semibold">Fine Settings</span>
                    </a>
                </div>
            </div>
        </div>
    </div>

</div><!-- /.page-content -->

<script>
document.addEventListener('DOMContentLoaded', function() {
    // 1. Borrowing Activity Trend Chart
    const trendCtx = document.getElementById('trendChart');
    if (trendCtx) {
        <%
            StringBuilder trendL = new StringBuilder();
            StringBuilder trendV = new StringBuilder();
            if (trends != null && !trends.isEmpty()) {
                for (java.util.Map.Entry<String, Integer> e : trends.entrySet()) {
                    if (trendL.length() > 0) { trendL.append(","); trendV.append(","); }
                    trendL.append("\"").append(e.getKey()).append("\"");
                    trendV.append(e.getValue());
                }
            } else {
                trendL.append("\"Day 1\",\"Day 2\",\"Day 3\",\"Day 4\",\"Day 5\",\"Day 6\",\"Today\"");
                trendV.append("0,0,0,0,0,0,0");
            }
        %>
        new Chart(trendCtx, {
            type: 'line',
            data: {
                labels: [<%= trendL.toString() %>],
                datasets: [{
                    label: 'Books Issued',
                    data: [<%= trendV.toString() %>],
                    borderColor: '#283f7d',
                    backgroundColor: 'rgba(40, 63, 125, 0.08)',
                    fill: true,
                    tension: 0.25,
                    borderWidth: 2,
                    pointBackgroundColor: '#ec633d',
                    pointRadius: 4
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { display: false }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        ticks: { stepSize: 1, precision: 0, color: '#595959', font: { family: "'Geist Mono', monospace", size: 11 } },
                        grid: { color: 'rgba(55, 55, 55, 0.1)' }
                    },
                    x: {
                        ticks: { color: '#595959', font: { family: "'Geist Mono', monospace", size: 11 } },
                        grid: { display: false }
                    }
                }
            }
        });
    }

    // 2. Category Donut Chart with Illoca Palette
    const catCtx = document.getElementById('categoryChart');
    if (catCtx) {
        <%
            StringBuilder catL = new StringBuilder();
            StringBuilder catV = new StringBuilder();
            if (catDist != null && !catDist.isEmpty()) {
                for (java.util.Map.Entry<String, Integer> e : catDist.entrySet()) {
                    if (catL.length() > 0) { catL.append(","); catV.append(","); }
                    catL.append("\"").append(e.getKey()).append("\"");
                    catV.append(e.getValue());
                }
            } else {
                catL.append("\"General\"");
                catV.append("1");
            }
        %>
        new Chart(catCtx, {
            type: 'doughnut',
            data: {
                labels: [<%= catL.toString() %>],
                datasets: [{
                    data: [<%= catV.toString() %>],
                    backgroundColor: [
                        '#283f7d', '#ec633d', '#1f6e43', '#945811', '#546387', '#373737', '#9aa0a6'
                    ],
                    borderWidth: 2,
                    borderColor: '#fffbf3'
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'bottom',
                        labels: { boxWidth: 12, padding: 10, font: { family: "'Geist Mono', monospace", size: 11 }, color: '#212121' }
                    }
                },
                cutout: '65%'
            }
        });
    }
});
</script>

<jsp:include page="includes/admin-footer.jsp" />
<jsp:include page="includes/footer.jsp" />
