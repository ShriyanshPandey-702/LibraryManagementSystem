<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="model.LostDamagedReport" %>
<%
    if (session.getAttribute("adminUser") == null) {
        response.sendRedirect(request.getContextPath() + "/LoginServlet");
        return;
    }
    List<LostDamagedReport> reports = (List<LostDamagedReport>) request.getAttribute("reports");
    String statusFilter = (String) request.getAttribute("statusFilter");
    if (statusFilter == null) statusFilter = "ALL";

    String flashSuccess = (String) session.getAttribute("flashSuccess");
    if (flashSuccess != null) session.removeAttribute("flashSuccess");

    String flashError = (String) session.getAttribute("flashError");
    if (flashError != null) session.removeAttribute("flashError");

    int count = reports != null ? reports.size() : 0;
%>
<jsp:include page="includes/header.jsp" />
<jsp:include page="includes/admin-navbar.jsp" />

<div class="page-content">

    <!-- Page Header -->
    <header class="page-header">
        <div>
            <h1 class="page-title">Lost &amp; Damaged Book Incidents</h1>
            <p class="page-subtitle">Review incident reports, inspect physical copy conditions, assess replacement penalties, and record resolutions.</p>
        </div>
        <div class="page-header-actions">
            <a href="<%= request.getContextPath() %>/DashboardServlet" class="btn-lib-secondary">
                <i class="fas fa-gauge-high me-1"></i> Dashboard
            </a>
        </div>
    </header>

    <!-- Flash Alerts -->
    <% if (flashSuccess != null && !flashSuccess.isEmpty()) { %>
        <div class="alert alert-success mb-4" role="alert">
            <i class="fas fa-check-circle me-2"></i><%= flashSuccess %>
        </div>
    <% } %>
    <% if (flashError != null && !flashError.isEmpty()) { %>
        <div class="alert alert-danger mb-4" role="alert">
            <i class="fas fa-circle-exclamation me-2"></i><%= flashError %>
        </div>
    <% } %>

    <!-- Filter Bar -->
    <div class="panel mb-4">
        <div class="panel-body py-3">
            <form method="get" action="<%= request.getContextPath() %>/AdminLostDamagedServlet" class="row g-2 align-items-center">
                <div class="col-md-4">
                    <label class="form-label font-mono small mb-1">// STATUS FILTER</label>
                    <select name="status" class="form-select" onchange="this.form.submit()">
                        <option value="ALL" <%= "ALL".equalsIgnoreCase(statusFilter) ? "selected" : "" %>>All Reports</option>
                        <option value="Pending" <%= "Pending".equalsIgnoreCase(statusFilter) ? "selected" : "" %>>Pending Review</option>
                        <option value="Under Review" <%= "Under Review".equalsIgnoreCase(statusFilter) ? "selected" : "" %>>Under Investigation</option>
                        <option value="Resolved" <%= "Resolved".equalsIgnoreCase(statusFilter) ? "selected" : "" %>>Resolved &amp; Assessed</option>
                        <option value="Rejected" <%= "Rejected".equalsIgnoreCase(statusFilter) ? "selected" : "" %>>Rejected / Dismissed</option>
                    </select>
                </div>
                <div class="col-md-2 d-grid align-self-end">
                    <a href="<%= request.getContextPath() %>/AdminLostDamagedServlet" class="btn-lib-secondary text-center">
                        <i class="fas fa-rotate-left me-1"></i> Reset
                    </a>
                </div>
            </form>
        </div>
    </div>

    <!-- Reports Table Panel -->
    <div class="panel">
        <div class="panel-header d-flex justify-content-between align-items-center">
            <div class="d-flex align-items-center gap-2">
                <h2 class="panel-title">Incident Reports Ledger</h2>
                <span class="badge-status badge-neutral"><%= count %> <%= count == 1 ? "Incident" : "Incidents" %></span>
            </div>
            <span class="text-muted small">Any assessed fee is directly synchronized with the student fine settlement ledger</span>
        </div>

        <div class="table-responsive">
            <table class="table-lib mb-0">
                <thead>
                    <tr>
                        <th style="width: 70px;">ID</th>
                        <th>Incident Details</th>
                        <th>Student Account</th>
                        <th>Circulation Loan</th>
                        <th class="text-center">Status</th>
                        <th class="text-end">Assessed Fee</th>
                        <th class="text-end" style="width: 140px;">Review Action</th>
                    </tr>
                </thead>
                <tbody>
                <%
                    if (reports != null && !reports.isEmpty()) {
                        for (LostDamagedReport rep : reports) {
                            boolean isLost = "Lost".equalsIgnoreCase(rep.getReportType());
                            boolean isPending = "Pending".equalsIgnoreCase(rep.getStatus());
                            boolean isResolved = "Resolved".equalsIgnoreCase(rep.getStatus());
                %>
                    <tr>
                        <td class="text-muted small">#<%= rep.getId() %></td>
                        <td>
                            <div>
                                <span class="badge-status <%= isLost ? "badge-danger" : "badge-warning" %> me-1">
                                    <%= rep.getReportType() %>
                                </span>
                                <strong class="book-title"><%= rep.getBookTitle() %></strong>
                            </div>
                            <div class="text-muted small mt-1 font-mono">
                                "<%= rep.getDescription() != null ? rep.getDescription() : "No details" %>"
                            </div>
                            <% if (rep.getAdminNotes() != null && !rep.getAdminNotes().trim().isEmpty()) { %>
                                <div class="text-muted small mt-1">
                                    <strong>Admin Resolution:</strong> <%= rep.getAdminNotes() %>
                                </div>
                            <% } %>
                        </td>
                        <td>
                            <strong><%= rep.getStudentName() != null ? rep.getStudentName() : "Student #" + rep.getStudentId() %></strong>
                            <div class="text-muted small">ID #<%= rep.getStudentId() %></div>
                        </td>
                        <td>
                            <div>Loan #<%= rep.getIssueId() %></div>
                            <div class="text-muted small">
                                <%= rep.getCreatedAt() != null ? rep.getCreatedAt().toString().substring(0, 16) : "—" %>
                            </div>
                        </td>
                        <td class="text-center">
                            <% if ("Pending".equalsIgnoreCase(rep.getStatus())) { %>
                                <span class="badge-status badge-warning">Pending Review</span>
                            <% } else if ("Under Review".equalsIgnoreCase(rep.getStatus())) { %>
                                <span class="badge-status badge-neutral">Investigating</span>
                            <% } else if ("Resolved".equalsIgnoreCase(rep.getStatus())) { %>
                                <span class="badge-status badge-success">Resolved</span>
                            <% } else if ("Rejected".equalsIgnoreCase(rep.getStatus())) { %>
                                <span class="badge-status badge-danger">Rejected</span>
                            <% } else { %>
                                <span class="badge-status badge-neutral"><%= rep.getStatus() %></span>
                            <% } %>
                        </td>
                        <td class="text-end fw-semibold <%= rep.getFineAmount() > 0 ? "text-danger" : "text-muted" %>">
                            <% if (rep.getFineAmount() > 0) { %>
                                ₹<%= String.format("%.2f", rep.getFineAmount()) %>
                            <% } else { %>
                                ₹0.00
                            <% } %>
                        </td>
                        <td class="text-end">
                            <button type="button" class="btn-lib-primary btn-sm"
                                    onclick="openAdminResolveModal(<%= rep.getId() %>, '<%= rep.getReportType() %>', '<%= rep.getBookTitle().replace("'", "\\'") %>', '<%= rep.getStatus() %>', <%= rep.getFineAmount() %>, '<%= rep.getAdminNotes() != null ? rep.getAdminNotes().replace("'", "\\'") : "" %>')">
                                <i class="fas fa-gavel me-1"></i> Resolve
                            </button>
                        </td>
                    </tr>
                <%      }
                    } else {
                %>
                    <tr>
                        <td colspan="7">
                            <div class="empty-state">
                                <div class="empty-state-icon">
                                    <i class="fas fa-shield-halved"></i>
                                </div>
                                <h3 class="empty-state-title">No incident reports</h3>
                                <p class="empty-state-text">
                                    There are no lost or damaged book incident reports currently registered under this filter.
                                </p>
                            </div>
                        </td>
                    </tr>
                <% } %>
                </tbody>
            </table>
        </div>
    </div>

</div><!-- /.page-content -->

<!-- Resolve Incident Modal -->
<div class="modal fade" id="resolveIncidentModal" tabindex="-1" aria-labelledby="resolveIncidentModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content" style="background-color: var(--color-surface); border: 1px solid var(--color-border);">
            <form action="<%= request.getContextPath() %>/AdminLostDamagedServlet" method="post">
                <input type="hidden" name="reportId" id="modalReportId">
                <div class="modal-header border-bottom">
                    <h5 class="modal-title font-display" id="resolveIncidentModalLabel">
                        <i class="fas fa-gavel text-accent me-2"></i>Review Incident Report
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <p class="text-muted small mb-3">
                        Reviewing: <strong id="modalBookTitleText" class="text-dark"></strong> (<span id="modalReportTypeText"></span>)
                    </p>
                    <div class="mb-3">
                        <label for="modalStatusSelect" class="form-label font-mono small">// REPORT STATUS</label>
                        <select name="status" id="modalStatusSelect" class="form-control" required>
                            <option value="Under Review">Under Review / Investigating</option>
                            <option value="Resolved">Resolved (Apply Assessment &amp; Finalize)</option>
                            <option value="Rejected">Rejected / Dismiss Incident</option>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label for="modalFineAmount" class="form-label font-mono small">// ASSESSED PENALTY / REPLACEMENT FEE (₹)</label>
                        <div class="input-group">
                            <span class="input-group-text">₹</span>
                            <input type="number" step="0.01" min="0" name="fineAmount" id="modalFineAmount" class="form-control" value="0.00" placeholder="0.00">
                        </div>
                        <div class="form-text small">Fee will be automatically recorded on the student's circulation fine record.</div>
                    </div>
                    <div class="mb-3">
                        <label for="modalAdminNotes" class="form-label font-mono small">// RESOLUTION NOTES &amp; PHYSICAL COPY HANDLING</label>
                        <textarea name="adminNotes" id="modalAdminNotes" rows="3" class="form-control" placeholder="Specify whether book is repaired, replaced, written off, or student settled cash..."></textarea>
                    </div>
                </div>
                <div class="modal-footer border-top">
                    <button type="button" class="btn-lib-secondary btn-sm" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn-lib-primary btn-sm">Save Resolution</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
function openAdminResolveModal(id, type, title, status, fine, notes) {
    document.getElementById('modalReportId').value = id;
    document.getElementById('modalBookTitleText').textContent = title;
    document.getElementById('modalReportTypeText').textContent = type;
    document.getElementById('modalStatusSelect').value = status;
    document.getElementById('modalFineAmount').value = fine ? fine.toFixed(2) : "0.00";
    document.getElementById('modalAdminNotes').value = notes || "";
    new bootstrap.Modal(document.getElementById('resolveIncidentModal')).show();
}
</script>

<jsp:include page="includes/admin-footer.jsp" />
<jsp:include page="includes/footer.jsp" />
