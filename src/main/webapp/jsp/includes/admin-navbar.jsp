<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<nav class="navbar navbar-expand-lg custom-navbar sticky-top">
  <div class="container-fluid">
    <a class="navbar-brand" href="${pageContext.request.contextPath}/DashboardServlet"><i class="fas fa-book-open me-2"></i>Admin Panel</a>
    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNavAdmin">
      <span class="navbar-toggler-icon" style="filter: invert(1);"></span>
    </button>
    <div class="collapse navbar-collapse" id="navbarNavAdmin">
      <ul class="navbar-nav me-auto">
        <li class="nav-item">
          <a class="nav-link" href="${pageContext.request.contextPath}/DashboardServlet"><i class="fas fa-chart-line me-1"></i> Dashboard</a>
        </li>
        <li class="nav-item dropdown">
          <a class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown"><i class="fas fa-book me-1"></i> Books</a>
          <ul class="dropdown-menu">
            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/AddBookServlet">Add Book</a></li>
            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/ViewBooksServlet">View Books</a></li>
          </ul>
        </li>
        <li class="nav-item">
          <a class="nav-link" href="${pageContext.request.contextPath}/IssueBookServlet"><i class="fas fa-hand-holding me-1"></i> Issue Book</a>
        </li>
        <li class="nav-item">
          <a class="nav-link" href="${pageContext.request.contextPath}/ReturnBookServlet"><i class="fas fa-undo me-1"></i> Return Book</a>
        </li>
        <li class="nav-item">
          <a class="nav-link" href="${pageContext.request.contextPath}/AdminBookRequestsServlet"><i class="fas fa-bell me-1"></i> Requests</a>
        </li>
        <li class="nav-item">
          <a class="nav-link" href="${pageContext.request.contextPath}/SettingsServlet"><i class="fas fa-cog me-1"></i> Settings</a>
        </li>
      </ul>
      <ul class="navbar-nav">
        <li class="nav-item">
          <a class="nav-link btn btn-danger text-white px-3 ms-2" href="${pageContext.request.contextPath}/LogoutServlet"><i class="fas fa-sign-out-alt me-1"></i> Logout</a>
        </li>
      </ul>
    </div>
  </div>
</nav>
