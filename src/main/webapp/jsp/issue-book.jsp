<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="model.Book" %>
<%@ page import="model.Student" %>
<%
    if (session.getAttribute("adminUser") == null) {
        response.sendRedirect(request.getContextPath() + "/LoginServlet");
        return;
    }
    String successMessage = (String) request.getAttribute("successMessage");
    String error = (String) request.getAttribute("error");
    Integer selectedBookId    = (Integer) request.getAttribute("selectedBookId");
    Integer selectedStudentId = (Integer) request.getAttribute("selectedStudentId");
    String selectedCourse     = (String) request.getAttribute("selectedCourse");
    String selectedYear       = (String) request.getAttribute("selectedYear");
    String selectedSection    = (String) request.getAttribute("selectedSection");
    Integer requestId         = (Integer) request.getAttribute("requestId");
    List<Book> books         = (List<Book>) request.getAttribute("books");
    List<Student> students   = (List<Student>) request.getAttribute("students");
%>
<jsp:include page="includes/header.jsp" />
<jsp:include page="includes/admin-navbar.jsp" />

<div class="page-content">

    <!-- Page Header -->
    <header class="page-header">
        <div>
            <h1 class="page-title">Issue Book</h1>
            <p class="page-subtitle">Authorize and record a book loan to an active student borrower.</p>
        </div>
        <div class="page-header-actions">
            <a href="<%= request.getContextPath() %>/ReturnBookServlet" class="btn-lib-secondary">
                <i class="fas fa-rotate-left me-1"></i> Return Book
            </a>
        </div>
    </header>

    <!-- Alerts -->
    <% if (successMessage != null && !successMessage.isEmpty()) { %>
        <div class="alert alert-success mb-4" role="alert">
            <i class="fas fa-check-circle me-2"></i><%= successMessage %>
        </div>
    <% } %>
    <% if (error != null && !error.trim().isEmpty()) { %>
        <div class="alert alert-danger mb-4" role="alert">
            <i class="fas fa-circle-exclamation me-2"></i><%= error %>
        </div>
    <% } %>

    <!-- Form Panel -->
    <div class="panel" style="max-width: 900px;">
        <div class="panel-header">
            <h2 class="panel-title">Circulation Assignment Form</h2>
        </div>
        <div class="panel-body">
            <form action="<%= request.getContextPath() %>/IssueBookServlet" method="post">
                <% if (requestId != null) { %>
                    <input type="hidden" name="requestId" value="<%= requestId %>">
                <% } %>

                <div class="row g-4">
                    <!-- Book Information Column -->
                    <div class="col-md-6 border-end-md">
                        <h3 class="h6 text-uppercase fw-bold text-muted mb-3" style="letter-spacing: 0.5px;">1. Book Selection</h3>
                        <div class="mb-3">
                            <label for="bookSelect" class="form-label">Available Book <span class="text-danger">*</span></label>
                            <select id="bookSelect" name="bookId" class="form-select" required>
                                <option value="">-- Choose a title from catalog --</option>
                                <%
                                    if (books != null) for (Book book : books) {
                                        boolean sel = selectedBookId != null && selectedBookId == book.getBookId();
                                %>
                                <option value="<%= book.getBookId() %>" <%= sel ? "selected" : "" %>>
                                    #<%= book.getBookId() %> &bull; <%= book.getTitle() %> (<%= book.getQuantity() %> copies)
                                </option>
                                <% } %>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label for="dueDateInput" class="form-label">Due Date <span class="text-danger">*</span></label>
                            <input type="date" id="dueDateInput" name="dueDate" class="form-control" required>
                            <div class="form-text">Standard loan period is 7 days from today.</div>
                        </div>
                    </div>

                    <!-- Student Information Column -->
                    <div class="col-md-6">
                        <h3 class="h6 text-uppercase fw-bold text-muted mb-3" style="letter-spacing: 0.5px;">2. Student Details</h3>
                        <div class="mb-3">
                            <label for="studentSelect" class="form-label">Registered Student <span class="text-danger">*</span></label>
                            <select id="studentSelect" name="studentId" class="form-select" required>
                                <option value="">-- Choose a student member --</option>
                                <%
                                    if (students != null) for (Student student : students) {
                                        boolean sel = selectedStudentId != null && selectedStudentId == student.getId();
                                %>
                                <option value="<%= student.getId() %>" <%= sel ? "selected" : "" %>
                                        data-course="<%= student.getCourse() != null ? student.getCourse() : "" %>"
                                        data-year="<%= student.getYear() != null ? student.getYear() : "" %>"
                                        data-section="<%= student.getSection() != null ? student.getSection() : "" %>">
                                    <%= student.getName() %> (<%= student.getEmail() %>)
                                </option>
                                <% } %>
                            </select>
                        </div>
                        <div class="row g-2">
                            <div class="col-4">
                                <label for="courseInput" class="form-label small">Course</label>
                                <input type="text" id="courseInput" name="course" class="form-control"
                                       value="<%= selectedCourse != null ? selectedCourse : "" %>" readonly>
                            </div>
                            <div class="col-4">
                                <label for="yearInput" class="form-label small">Year</label>
                                <input type="text" id="yearInput" name="year" class="form-control"
                                       value="<%= selectedYear != null ? selectedYear : "" %>" readonly>
                            </div>
                            <div class="col-4">
                                <label for="sectionInput" class="form-label small">Section</label>
                                <input type="text" id="sectionInput" name="section" class="form-control"
                                       value="<%= selectedSection != null ? selectedSection : "" %>" readonly>
                                <input type="hidden" name="otherSection" value="">
                            </div>
                        </div>
                    </div>
                </div>

                <div class="d-flex gap-2 mt-4 pt-3 border-top">
                    <button type="submit" class="btn-lib-primary px-4">
                        <i class="fas fa-check me-1"></i> Confirm Issue Loan
                    </button>
                    <a href="<%= request.getContextPath() %>/DashboardServlet" class="btn-lib-secondary">
                        Cancel
                    </a>
                </div>
            </form>
        </div>
    </div>

</div><!-- /.page-content -->

<script>
const studentSelect = document.getElementById('studentSelect');
const courseInput   = document.getElementById('courseInput');
const yearInput     = document.getElementById('yearInput');
const sectionInput  = document.getElementById('sectionInput');

if (studentSelect) {
    studentSelect.addEventListener('change', function() {
        const opt = this.options[this.selectedIndex];
        if (!opt || this.value === '') {
            courseInput.value = yearInput.value = sectionInput.value = '';
            return;
        }
        courseInput.value  = opt.dataset.course  || '';
        yearInput.value    = opt.dataset.year    || '';
        sectionInput.value = opt.dataset.section || '';
    });
    if (studentSelect.value) studentSelect.dispatchEvent(new Event('change'));
}

(function() {
    const d = document.getElementById('dueDateInput');
    if (!d) return;
    const today = new Date().toISOString().split('T')[0];
    d.min = today;
    if (!d.value) {
        const nw = new Date();
        nw.setDate(nw.getDate() + 7);
        d.value = nw.toISOString().split('T')[0];
    }
})();
</script>

<jsp:include page="includes/admin-footer.jsp" />
<jsp:include page="includes/footer.jsp" />
