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
            </a>

            <a href="<%= ctx %>/AdminReservationsServlet" class="sidebar-link <%= currentUri.contains("AdminReservationsServlet") ? "active" : "" %>">
                <i class="fas fa-calendar-check"></i>
                <span>Reservations &amp; Waitlist</span>
            </a>

            <a href="<%= ctx %>/AdminLostDamagedServlet" class="sidebar-link <%= currentUri.contains("AdminLostDamagedServlet") ? "active" : "" %>">
                <i class="fas fa-triangle-exclamation"></i>
                <span>Lost / Damaged Reports</span>
            </a>

            <div class="sidebar-section-label">// 04 CONFIGURATION</div>

            <a href="<%= ctx %>/FineSettingsServlet" class="sidebar-link <%= currentUri.contains("FineSettingsServlet") ? "active" : "" %>">
                <i class="fas fa-sliders"></i>
                <span>Library Policies</span>
            </a>

            <a href="<%= ctx %>/SettingsServlet" class="sidebar-link <%= currentUri.contains("SettingsServlet") ? "active" : "" %>">
                <i class="fas fa-users-gear"></i>
                <span>Students Roster</span>
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

        <!-- Top Utility Bar (Theme Toggle & Notifications) -->
        <header class="topbar-utility px-4 py-2 border-bottom d-flex align-items-center justify-content-between" style="background-color: var(--color-surface);">
            <div class="d-flex align-items-center gap-2">
                <button id="sidebarToggle" class="btn-lib-secondary btn-sm d-md-none" aria-label="Toggle navigation menu">
                    <i class="fas fa-bars"></i>
                </button>
                <span class="font-mono text-muted small">// ADMIN OPERATIONS</span>
            </div>

            <div class="d-flex align-items-center gap-3">
                <!-- Theme Toggle Button -->
                <button type="button" class="btn-theme-toggle" id="themeToggleBtn" aria-label="Toggle theme" title="Toggle Light / Dark mode">
                    <i class="fas fa-moon"></i>
                </button>

                <!-- Notifications Dropdown -->
                <div class="notif-wrapper">
                    <button type="button" class="notif-bell-btn" id="notifBellBtn" aria-label="View notifications">
                        <i class="fas fa-bell"></i>
                        <span class="notif-badge d-none" id="notifBadge">0</span>
                    </button>
                    <div class="notif-dropdown" id="notifDropdown">
                        <div class="notif-header">
                            <span>Notifications</span>
                            <button type="button" class="btn btn-link btn-sm p-0 text-decoration-none small" id="markAllReadBtn">Mark all as read</button>
                        </div>
                        <div id="notifList">
                            <div class="p-3 text-center text-muted small">No notifications.</div>
                        </div>
                    </div>
                </div>

                <a href="<%= ctx %>/LogoutServlet" class="btn-lib-secondary btn-sm" title="Sign out" aria-label="Sign out">
                    <i class="fas fa-arrow-right-from-bracket me-1"></i> Sign Out
                </a>
            </div>
        </header>

        <!-- Page content injected here -->
