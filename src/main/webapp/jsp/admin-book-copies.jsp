<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="model.Book" %>
<%@ page import="model.BookCopy" %>
<%
    if (session.getAttribute("adminUser") == null) {
        response.sendRedirect(request.getContextPath() + "/LoginServlet");
        return;
    }
    Book book = (Book) request.getAttribute("book");
    List<BookCopy> copies = (List<BookCopy>) request.getAttribute("copies");

    String flashSuccess = (String) session.getAttribute("flashSuccess");
    if (flashSuccess != null) session.removeAttribute("flashSuccess");

    String flashError = (String) session.getAttribute("flashError");
    if (flashError != null) session.removeAttribute("flashError");

    int copyCount = copies != null ? copies.size() : 0;
%>
<jsp:include page="includes/header.jsp" />
<jsp:include page="includes/admin-navbar.jsp" />

<div class="page-content">

    <!-- Page Header -->
    <header class="page-header">
        <div>
            <h1 class="page-title">Physical Copies &amp; Barcode Ledger</h1>
            <% if (book != null) { %>
                <p class="page-subtitle">Tracking <%= copyCount %> physical copies for: <strong><%= book.getTitle() %></strong> by <%= book.getAuthor() %> (ID #<%= book.getBookId() %>)</p>
            <% } %>
        </div>
        <div class="page-header-actions">
            <button type="button" class="btn-lib-secondary" onclick="window.print()">
                <i class="fas fa-print me-1"></i> Print Barcode Labels
            </button>
            <a href="<%= request.getContextPath() %>/ViewBooksServlet" class="btn-lib-primary">
                <i class="fas fa-arrow-left me-1"></i> Back to Catalog
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

    <!-- Copies Table Panel -->
    <div class="panel">
        <div class="panel-header d-flex justify-content-between align-items-center">
            <div class="d-flex align-items-center gap-2">
                <h2 class="panel-title">Tracked Physical Copies</h2>
                <span class="badge-status badge-neutral"><%= copyCount %> Copies</span>
            </div>
            <span class="text-muted small">Unique barcode identifiers can be printed onto spine labels or scanned at the circulation desk</span>
        </div>

        <div class="table-responsive">
            <table class="table-lib mb-0">
                <thead>
                    <tr>
                        <th style="width: 80px;">Copy #</th>
                        <th>Barcode Identifier</th>
                        <th>Spine Barcode Tag</th>
                        <th class="text-center">Current Status</th>
                        <th>Condition Notes</th>
                        <th>Added Date</th>
                        <th class="text-end" style="width: 120px;">Action</th>
                    </tr>
                </thead>
                <tbody>
                <%
                    if (copies != null && !copies.isEmpty()) {
                        for (BookCopy cp : copies) {
                            String st = cp.getStatus();
                            boolean isAvail = "Available".equalsIgnoreCase(st);
                            boolean isBorrowed = "Borrowed".equalsIgnoreCase(st);
                            boolean isReserved = "Reserved".equalsIgnoreCase(st);
                            boolean isDamaged = "Damaged".equalsIgnoreCase(st);
                            boolean isLost = "Lost".equalsIgnoreCase(st);
                %>
                    <tr>
                        <td class="text-muted font-mono small">#<%= cp.getCopyNumber() %></td>
                        <td>
                            <strong class="font-mono"><%= cp.getBarcode() %></strong>
                            <div class="text-muted small">UID: <%= cp.getId() %></div>
                        </td>
                        <td>
                            <!-- Stylized printable barcode preview -->
                            <div class="barcode-tag d-inline-flex flex-column align-items-center p-2 rounded" style="background: #fff; border: 1px dashed var(--color-border); min-width: 130px;">
                                <div style="font-family: 'Geist Mono', monospace; letter-spacing: 3px; font-weight: 700; font-size: 1.1rem; color: #111;">
                                    ||||| | ||| |||| |
                                </div>
                                <span class="font-mono small text-dark fw-bold mt-1" style="font-size: 0.75rem;"><%= cp.getBarcode() %></span>
                            </div>
                        </td>
                        <td class="text-center">
                            <% if (isAvail) { %>
                                <span class="badge-status badge-success">Available</span>
                            <% } else if (isBorrowed) { %>
                                <span class="badge-status badge-warning">On Loan</span>
                            <% } else if (isReserved) { %>
                                <span class="badge-status badge-neutral">Reserved</span>
                            <% } else if (isDamaged) { %>
                                <span class="badge-status badge-danger">Damaged</span>
                            <% } else if (isLost) { %>
                                <span class="badge-status badge-danger">Lost</span>
                            <% } else { %>
                                <span class="badge-status badge-neutral"><%= st %></span>
                            <% } %>
                        </td>
                        <td class="text-muted small">
                            <%= cp.getConditionNotes() != null && !cp.getConditionNotes().trim().isEmpty() ? cp.getConditionNotes() : "Good condition" %>
                        </td>
                        <td class="text-muted small">
                            <%= cp.getCreatedAt() != null ? cp.getCreatedAt().toString().substring(0, 10) : "—" %>
                        </td>
                        <td class="text-end">
                            <button type="button" class="btn-lib-secondary btn-sm"
                                    onclick="openEditCopyModal(<%= cp.getId() %>, '<%= cp.getBarcode() %>', '<%= cp.getStatus() %>', '<%= cp.getConditionNotes() != null ? cp.getConditionNotes().replace("'", "\\'") : "" %>')">
                                <i class="fas fa-pen-to-square me-1"></i> Status
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
                                    <i class="fas fa-barcode"></i>
                                </div>
                                <h3 class="empty-state-title">No physical copies tracked</h3>
                                <p class="empty-state-text">
                                    Copies are automatically generated when book inventory quantity is increased.
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

<!-- Edit Copy Status Modal -->
<div class="modal fade" id="editCopyModal" tabindex="-1" aria-labelledby="editCopyModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content" style="background-color: var(--color-surface); border: 1px solid var(--color-border);">
            <form action="<%= request.getContextPath() %>/AdminBookCopiesServlet" method="post">
                <input type="hidden" name="action" value="updateCopyStatus">
                <input type="hidden" name="bookId" value="<%= book != null ? book.getBookId() : "" %>">
                <input type="hidden" name="copyId" id="modalCopyId">
                <div class="modal-header border-bottom">
                    <h5 class="modal-title font-display" id="editCopyModalLabel">
                        <i class="fas fa-barcode text-accent me-2"></i>Update Physical Copy Condition
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <p class="text-muted small mb-3">
                        Barcode: <strong id="modalCopyBarcodeText" class="font-mono text-dark"></strong>
                    </p>
                    <div class="mb-3">
                        <label for="modalCopyStatus" class="form-label font-mono small">// PHYSICAL STATUS</label>
                        <select name="status" id="modalCopyStatus" class="form-control" required>
                            <option value="Available">Available (On Shelf)</option>
                            <option value="Borrowed">Borrowed (Circulation)</option>
                            <option value="Reserved">Reserved (Holding Shelf)</option>
                            <option value="Damaged">Damaged (Needs Repair)</option>
                            <option value="Lost">Lost (Missing)</option>
                            <option value="Under Repair">Under Repair / Conservation</option>
                            <option value="Withdrawn">Withdrawn from Catalog</option>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label for="modalCopyNotes" class="form-label font-mono small">// CONDITION NOTES &amp; INSPECTION LOG</label>
                        <textarea name="conditionNotes" id="modalCopyNotes" rows="3" class="form-control" placeholder="Note any torn pages, spine wear, water stains, or repairs..."></textarea>
                    </div>
                </div>
                <div class="modal-footer border-top">
                    <button type="button" class="btn-lib-secondary btn-sm" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn-lib-primary btn-sm">Save Changes</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
function openEditCopyModal(copyId, barcode, status, notes) {
    document.getElementById('modalCopyId').value = copyId;
    document.getElementById('modalCopyBarcodeText').textContent = barcode;
    document.getElementById('modalCopyStatus').value = status;
    document.getElementById('modalCopyNotes').value = notes || "";
    new bootstrap.Modal(document.getElementById('editCopyModal')).show();
}
</script>

<jsp:include page="includes/admin-footer.jsp" />
<jsp:include page="includes/footer.jsp" />
