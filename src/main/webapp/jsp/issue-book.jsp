<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="model.Book" %>
<%@ page import="model.Student" %>
<%
    if (session.getAttribute("adminUser") == null) {
        response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
        return;
    }
%>
<jsp:include page="includes/header.jsp" />
<jsp:include page="includes/admin-navbar.jsp" />

<div class="main-content bg-light">
    <div class="container py-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h3 class="fw-bold"><i class="fas fa-hand-holding me-2 text-warning"></i>Issue Book</h3>
            <a href="<%= request.getContextPath() %>/ReturnBookServlet" class="btn btn-outline-info"><i class="fas fa-undo me-1"></i>Return Book</a>
        </div>

        <% String successMessage = (String) request.getAttribute("successMessage"); %>
        <% String error = (String) request.getAttribute("error"); %>
        <% if (successMessage != null) { %>
            <div class="alert alert-success shadow-sm"><i class="fas fa-check-circle me-2"></i><%= successMessage %></div>
        <% } %>
        <% if (error != null && !error.trim().isEmpty()) { %>
            <div class="alert alert-danger shadow-sm"><i class="fas fa-exclamation-circle me-2"></i><%= error %></div>
        <% } %>

        <% Integer selectedBookId = (Integer) request.getAttribute("selectedBookId"); %>
        <% Integer selectedStudentId = (Integer) request.getAttribute("selectedStudentId"); %>
        <% String selectedCourse = (String) request.getAttribute("selectedCourse"); %>
        <% String selectedYear = (String) request.getAttribute("selectedYear"); %>
        <% String selectedSection = (String) request.getAttribute("selectedSection"); %>
        <% Integer requestId = (Integer) request.getAttribute("requestId"); %>

        <div class="glass-card">
            <form action="<%= request.getContextPath() %>/IssueBookServlet" method="post">
                <% if (requestId != null) { %>
                    <input type="hidden" name="requestId" value="<%= requestId %>">
                <% } %>
                
                <div class="row g-4">
                    <div class="col-md-6">
                        <div class="card border-0 bg-light h-100">
                            <div class="card-body">
                                <h5 class="card-title fw-bold text-primary mb-3"><i class="fas fa-book me-2"></i>Book Details</h5>
                                <div class="mb-3">
                                    <label class="form-label fw-bold">Select Book</label>
                                    <select name="bookId" class="form-select border-0 shadow-sm" required>
                                        <option value="">Choose a book</option>
                                        <%
                                            List<Book> books = (List<Book>) request.getAttribute("books");
                                            if (books != null && !books.isEmpty()) {
                                                for (Book book : books) {
                                        %>
                                        <option value="<%= book.getBookId() %>" <%= (selectedBookId != null && selectedBookId == book.getBookId()) ? "selected" : "" %>>
                                            <%= book.getBookId() %> - <%= book.getTitle() %> (Qty: <%= book.getQuantity() %>)
                                        </option>
                                        <%
                                                }
                                            } else {
                                        %>
                                        <option value="" disabled>No available books</option>
                                        <%
                                            }
                                        %>
                                    </select>
                                </div>
                                
                                <div class="mb-3">
                                    <label class="form-label fw-bold">Due Date</label>
                                    <input type="date" id="dueDateInput" name="dueDate" class="form-control border-0 shadow-sm" required>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-md-6">
                        <div class="card border-0 bg-light h-100">
                            <div class="card-body">
                                <h5 class="card-title fw-bold text-info mb-3"><i class="fas fa-user-graduate me-2"></i>Student Details</h5>
                                
                                <div class="mb-3">
                                    <label class="form-label fw-bold">Select Student</label>
                                    <select id="studentSelect" name="studentId" class="form-select border-0 shadow-sm" required>
                                        <option value="">Choose a student</option>
                                        <%
                                            List<Student> students = (List<Student>) request.getAttribute("students");
                                            if (students != null && !students.isEmpty()) {
                                                for (Student student : students) {
                                        %>
                                        <option value="<%= student.getId() %>" <%= (selectedStudentId != null && selectedStudentId == student.getId()) ? "selected" : "" %>
                                                data-course="<%= student.getCourse() %>"
                                                data-year="<%= student.getYear() %>"
                                                data-section="<%= student.getSection() != null ? student.getSection() : "" %>">
                                            <%= student.getName() %> | <%= student.getEmail() %>
                                        </option>
                                        <%
                                                }
                                            } else {
                                        %>
                                        <option value="">No students found</option>
                                        <%
                                            }
                                        %>
                                    </select>
                                </div>

                                <div class="row g-2">
                                    <div class="col-md-4 mb-3">
                                        <label class="form-label fw-bold">Course</label>
                                        <input type="text" id="courseInput" name="course" class="form-control border-0 shadow-sm bg-white" value="<%= selectedCourse == null ? "" : selectedCourse %>" required readonly>
                                    </div>

                                    <div class="col-md-4 mb-3">
                                        <label class="form-label fw-bold">Year</label>
                                        <input type="text" id="yearInput" name="year" class="form-control border-0 shadow-sm bg-white" value="<%= selectedYear == null ? "" : selectedYear %>" required readonly>
                                    </div>

                                    <div class="col-md-4 mb-3">
                                        <label class="form-label fw-bold">Section</label>
                                        <input type="text" id="sectionInput" name="section" class="form-control border-0 shadow-sm bg-white" value="<%= selectedSection == null ? "" : selectedSection %>" required readonly>
                                        <!-- Keep these around to prevent form breaking if Servlet checks for otherSection, though we made them readonly -->
                                        <input type="hidden" name="otherSection" value="">
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="mt-4 pt-3 border-top d-flex gap-2 justify-content-center">
                    <button type="submit" class="btn btn-warning px-5 fw-bold text-dark shadow-sm"><i class="fas fa-hand-holding me-1"></i> Issue Book Now</button>
                    <a href="<%= request.getContextPath() %>/DashboardServlet" class="btn btn-light border px-4 shadow-sm"><i class="fas fa-times me-1"></i> Cancel</a>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    const studentSelect = document.getElementById("studentSelect");
    const courseInput = document.getElementById("courseInput");
    const yearInput = document.getElementById("yearInput");
    const sectionInput = document.getElementById("sectionInput");

    if (studentSelect) {
        studentSelect.addEventListener("change", function () {
            const option = this.options[this.selectedIndex];
            if (!option || this.value === "") {
                courseInput.value = "";
                yearInput.value = "";
                sectionInput.value = "";
                return;
            }
            courseInput.value = option.getAttribute("data-course") || "";
            yearInput.value = option.getAttribute("data-year") || "";
            sectionInput.value = option.getAttribute("data-section") || "A"; // default
        });
        
        // Trigger change on load if selected
        if(studentSelect.value !== "") {
            studentSelect.dispatchEvent(new Event('change'));
        }
    }
    
    // Default due date to +7 days and set min to today
    document.addEventListener("DOMContentLoaded", function() {
        const dateInput = document.getElementById('dueDateInput');
        if (dateInput) {
            const today = new Date();
            const formattedToday = today.toISOString().split('T')[0];
            dateInput.setAttribute('min', formattedToday);
            
            if (!dateInput.value) {
                const nextWeek = new Date();
                nextWeek.setDate(nextWeek.getDate() + 7);
                const formattedNextWeek = nextWeek.toISOString().split('T')[0];
                dateInput.value = formattedNextWeek;
            }
        }
    });
</script>

<jsp:include page="includes/footer.jsp" />
