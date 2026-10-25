<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String currentUri = request.getRequestURI();
    String ctx = request.getContextPath();
    Object adminUser = session != null ? session.getAttribute("adminUser") : null;
    String adminName = adminUser != null ? adminUser.toString() : "Admin";
    String initial = !adminName.isEmpty() ? adminName.substring(0, 1).toUpperCase() : "A";
%>
<div class="app-shell">

    <!-- ── Admin Sidebar (Solid ink/teal) ───────────────── -->
    <aside class="sidebar" id="appSidebar" aria-label="Administrator Navigation">

        <a href="<%= ctx %>/DashboardServlet" class="sidebar-brand">
            <span class="sidebar-brand-icon">
                <i class="fas fa-book-bookmark"></i>
            </span>
            <div class="sidebar-brand-text">
                libris<span style="color: var(--color-accent); font-weight: 700;">.</span>
                <div class="sidebar-brand-sub">Staff Console</div>
            </div>
        </a>

        <nav class="sidebar-nav">

            <div class="sidebar-section-label">// 01 OVERVIEW</div>

            <a href="<%= ctx %>/DashboardServlet" class="sidebar-link <%= currentUri.contains("DashboardServlet") ? "active" : "" %>">
                <i class="fas fa-gauge-high"></i>
                <span>Dashboard</span>
            </a>

            <div class="sidebar-section-label">// 02 CATALOG</div>

            <a href="<%= ctx %>/ViewBooksServlet" class="sidebar-link <%= currentUri.contains("ViewBooksServlet") ? "active" : "" %>">
                <i class="fas fa-book"></i>
                <span>Book Catalog</span>
            </a>

            <a href="<%= ctx %>/AddBookServlet" class="sidebar-link <%= currentUri.contains("AddBookServlet") ? "active" : "" %>">
                <i class="fas fa-plus"></i>
                <span>Add New Book</span>
            </a>

            <div class="sidebar-section-label">// 03 CIRCULATION</div>

            <a href="<%= ctx %>/IssueBookServlet" class="sidebar-link <%= currentUri.contains("IssueBookServlet") ? "active" : "" %>">
                <i class="fas fa-arrow-right-arrow-left"></i>
                <span>Issue Book</span>
            </a>

            <a href="<%= ctx %>/ReturnBookServlet" class="sidebar-link <%= currentUri.contains("ReturnBookServlet") ? "active" : "" %>">
                <i class="fas fa-rotate-left"></i>
                <span>Return Book</span>
            </a>

            <a href="<%= ctx %>/AdminBookRequestsServlet" class="sidebar-link <%= currentUri.contains("AdminBookRequestsServlet") ? "active" : "" %>">
                <i class="fas fa-inbox"></i>
                <span>Student Requests</span>
                <%
                    Object pending = session != null ? session.getAttribute("pendingRequestCount") : null;
                    if (pending != null && (Integer) pending > 0) {
                %>
                    <span class="sidebar-badge"><%= pending %></span>
                <% } %>
            </a>

            <div class="sidebar-section-label">// 04 ADMINISTRATION</div>

            <a href="<%= ctx %>/FineSettingsServlet" class="sidebar-link <%= currentUri.contains("FineSettingsServlet") ? "active" : "" %>">
                <i class="fas fa-receipt"></i>
                <span>Fine Settings</span>
            </a>

            <a href="<%= ctx %>/SettingsServlet" class="sidebar-link <%= currentUri.contains("SettingsServlet") ? "active" : "" %>">
                <i class="fas fa-sliders"></i>
                <span>System &amp; Students</span>
            </a>

        </nav>

        <div class="sidebar-footer">
            <div class="sidebar-user">
                <div class="sidebar-user-avatar"><%= initial %></div>
                <div class="sidebar-user-info">
                    <div class="sidebar-user-name"><%= adminName %></div>
                    <div class="sidebar-user-role">Administrator</div>
                </div>
            </div>
            <a href="<%= ctx %>/LogoutServlet" class="sidebar-logout-btn" title="Sign out of Admin Console" aria-label="Sign out">
                <i class="fas fa-arrow-right-from-bracket"></i>
            </a>
        </div>
    </aside>

    <!-- ── Main Area ────────────────────────────────────── -->
    <div class="main-area">

        <!-- Mobile Top Bar -->
        <header class="topbar-mobile">
            <button id="sidebarToggle" class="btn-lib-secondary btn-sm" aria-label="Toggle navigation menu">
                <i class="fas fa-bars"></i>
            </button>
            <span class="fw-semibold text-dark small">Admin Console</span>
            <a href="<%= ctx %>/LogoutServlet" class="btn-lib-secondary btn-sm" title="Sign out" aria-label="Sign out">
                <i class="fas fa-arrow-right-from-bracket"></i>
            </a>
        </header>

        <!-- Page content injected here -->
