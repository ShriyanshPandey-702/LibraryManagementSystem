<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    boolean isAdminLoggedIn = session.getAttribute("adminUser") != null;
    boolean isStudentLoggedIn = session.getAttribute("studentUser") != null;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Academic Library Management System - Catalog management, circulation, and student self-service.">
    <title>Library Management System — Libris</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome 6 -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <!-- Google Fonts (Illoca aesthetic: Space Grotesk, Geist Mono, DM Sans, Caveat) -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Caveat:wght@600;700&family=DM+Sans:ital,opsz,wght@0,9..40,400;0,9..40,500;0,9..40,600;1,9..40,400&family=Geist+Mono:wght@400;500;600;700&family=Space+Grotesk:wght@500;600;700&display=swap" rel="stylesheet">
    <!-- Master Custom CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body class="landing-body bg-grid">

    <!-- Top Navigation / Brand Bar -->
    <header class="landing-header">
        <div class="landing-header-inner">
            <a href="${pageContext.request.contextPath}/" class="landing-brand">
                <span class="landing-brand-icon"><i class="fas fa-book-bookmark"></i></span>
                <span class="landing-brand-text">libris<span style="color: var(--color-accent); font-weight: 700;">.</span></span>
            </a>
            <nav class="landing-nav-links" aria-label="Portal Navigation">
                <% if (isAdminLoggedIn) { %>
                    <a href="${pageContext.request.contextPath}/DashboardServlet" class="btn-lib-primary btn-sm">
                        <i class="fas fa-gauge-high"></i> Admin Console
                    </a>
                <% } else if (isStudentLoggedIn) { %>
                    <a href="${pageContext.request.contextPath}/StudentDashboardServlet" class="btn-lib-primary btn-sm">
                        <i class="fas fa-user-graduate"></i> Student Portal
                    </a>
                <% } else { %>
                    <a href="${pageContext.request.contextPath}/LoginServlet" class="landing-link">
                        Admin Login
                    </a>
                    <a href="${pageContext.request.contextPath}/StudentLoginServlet" class="btn-lib-primary btn-sm">
                        Try for free
                    </a>
                <% } %>
            </nav>
        </div>
    </header>

    <main id="main-content">
        <!-- Hero Section (Illoca Architectural Draft Style) -->
        <section class="landing-hero" aria-labelledby="hero-title">
            <div class="landing-hero-container">
                <div class="landing-hero-content">
                    <div class="sketch-note sketch-callout">ARCHITECTURAL</div>
                    <h1 id="hero-title" class="landing-title">Library operations at the speed of thought</h1>
                    <div class="sketch-note sketch-callout-bottom">NOT LEGACY SOFTWARE ↗</div>
                    
                    <p class="landing-lead mt-3">
                        A unified platform engineered for institutional libraries. Catalog inventories with precision, monitor circulation loans, process instant returns, and handle overdue settlements.
                    </p>

                    <div class="landing-actions mt-4">
                        <% if (isAdminLoggedIn) { %>
                            <a href="${pageContext.request.contextPath}/DashboardServlet" class="btn-lib-primary">
                                <i class="fas fa-gauge-high"></i> Open Admin Console
                            </a>
                        <% } else if (isStudentLoggedIn) { %>
                            <a href="${pageContext.request.contextPath}/StudentDashboardServlet" class="btn-lib-primary">
                                <i class="fas fa-user-graduate"></i> Open Student Portal
                            </a>
                        <% } else { %>
                            <a href="${pageContext.request.contextPath}/StudentLoginServlet" class="btn-lib-primary">
                                Try for free
                            </a>
                            <a href="#portal-selection" class="button-demo">
                                <span class="square"><i class="fas fa-chevron-right"></i></span>
                                <span class="label">Watch the demo</span>
                            </a>
                        <% } %>
                    </div>
                </div>

                <!-- Portal Selection Cards (Layered Draft Paper Cards) -->
                <div class="landing-portals-grid" id="portal-selection">
                    <!-- Administrator Portal Card -->
                    <div class="landing-portal-card">
                        <div class="d-flex align-items-center justify-content-between mb-2">
                            <span class="font-mono text-muted small">// 01 PORTAL</span>
                            <span class="badge-status neutral">STAFF DESK</span>
                        </div>
                        <div class="landing-portal-badge admin">
                            <i class="fas fa-shield-halved"></i>
                        </div>
                        <h2 class="landing-portal-title">Administrator Console</h2>
                        <p class="landing-portal-desc">
                            Full operational control over book inventories, issue authorizations, loan returns, student request approvals, and fine rate configuration.
                        </p>
                        <div class="landing-portal-action">
                            <a href="${pageContext.request.contextPath}/LoginServlet" class="btn-lib-primary w-100">
                                <%= isAdminLoggedIn ? "Go to Dashboard" : "Administrator Sign In" %>
                                <i class="fas fa-arrow-right"></i>
                            </a>
                        </div>
                        <div class="landing-portal-meta">
                            <span>Authorized library staff and administrators</span>
                        </div>
                    </div>

                    <!-- Student Portal Card -->
                    <div class="landing-portal-card">
                        <div class="d-flex align-items-center justify-content-between mb-2">
                            <span class="font-mono text-muted small">// 02 PORTAL</span>
                            <span class="badge-status success">SELF-SERVICE</span>
                        </div>
                        <div class="landing-portal-badge student">
                            <i class="fas fa-user-graduate"></i>
                        </div>
                        <h2 class="landing-portal-title">Student Portal</h2>
                        <p class="landing-portal-desc">
                            Search the physical library catalog, submit book reservation requests, track active loans, apply for self-service renewals, and check fines.
                        </p>
                        <div class="landing-portal-action">
                            <a href="${pageContext.request.contextPath}/StudentLoginServlet" class="btn-lib-secondary w-100">
                                <%= isStudentLoggedIn ? "Go to Student Portal" : "Student Sign In" %>
                                <i class="fas fa-arrow-right"></i>
                            </a>
                        </div>
                        <div class="landing-portal-meta">
                            <span>New student? <a href="${pageContext.request.contextPath}/StudentRegisterServlet">Register an account</a></span>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- Capabilities Section (Illoca Architectural Features) -->
        <section class="landing-section" id="capabilities" aria-labelledby="capabilities-title">
            <div class="landing-section-container">
                <div class="landing-section-header">
                    <div class="sketch-note text-muted" style="font-size: 1.3rem;">INTENTS, TRANSLATED!</div>
                    <h2 id="capabilities-title" class="landing-section-title">Engineered for reliable daily operations</h2>
                    <p class="landing-section-subtitle">
                        Built for library administrators and students with honest data, consistent rules, and zero clutter.
                    </p>
                </div>

                <div class="landing-grid-3">
                    <div class="panel">
                        <div class="panel-header">
                            <span class="panel-title"><span class="circled-num">1</span> Central Catalog</span>
                            <span class="badge-status neutral">INVENTORY</span>
                        </div>
                        <div class="panel-body">
                            <p class="text-muted small mb-3">
                                Maintain complete records of titles, authors, categories, ISBNs, shelf rack locations, and real-time physical copy counts.
                            </p>
                            <ul class="list-engineering">
                                <li><i class="fas fa-check text-success"></i> Real-time stock status monitoring</li>
                                <li><i class="fas fa-check text-success"></i> CSV spreadsheet catalog export</li>
                                <li><i class="fas fa-check text-success"></i> Soft-deletion &amp; audit protection</li>
                            </ul>
                        </div>
                    </div>

                    <div class="panel">
                        <div class="panel-header">
                            <span class="panel-title"><span class="circled-num">2</span> Circulation Desk</span>
                            <span class="badge-status neutral">QUOTA</span>
                        </div>
                        <div class="panel-body">
                            <p class="text-muted small mb-3">
                                Manage book loans and returns with strict borrowing limits (up to 3 books per student) and automated due date tracking.
                            </p>
                            <ul class="list-engineering">
                                <li><i class="fas fa-check text-success"></i> 3-book limit enforcement</li>
                                <li><i class="fas fa-check text-success"></i> 7-day self-service renewal</li>
                                <li><i class="fas fa-check text-success"></i> Overdue alert calculations</li>
                            </ul>
                        </div>
                    </div>

                    <div class="panel">
                        <div class="panel-header">
                            <span class="panel-title"><span class="circled-num">3</span> Fine Settlement</span>
                            <span class="badge-status neutral">ACCOUNTING</span>
                        </div>
                        <div class="panel-body">
                            <p class="text-muted small mb-3">
                                Automatically calculate overdue fines based on administrator-configured daily rates with itemized fee tracking.
                            </p>
                            <ul class="list-engineering">
                                <li><i class="fas fa-check text-success"></i> Configurable daily rates</li>
                                <li><i class="fas fa-check text-success"></i> Transparent settlement receipts</li>
                                <li><i class="fas fa-check text-success"></i> Audit log reconciliation</li>
                            </ul>
                        </div>
                    </div>
                </div>
            </div>
        </section>
    </main>

    <!-- Clean Editorial Footer -->
    <footer class="landing-footer">
        <div class="landing-footer-container">
            <div class="landing-footer-brand">
                <span class="landing-brand-text">libris.</span>
                <span class="landing-footer-sep">&bull;</span>
                <span class="landing-footer-copy">Academic Library Management Platform</span>
            </div>
            <div class="landing-footer-links">
                <a href="${pageContext.request.contextPath}/LoginServlet">Staff Sign In</a>
                <a href="${pageContext.request.contextPath}/StudentLoginServlet">Student Portal</a>
                <a href="${pageContext.request.contextPath}/StudentRegisterServlet">Registration</a>
            </div>
        </div>
    </footer>

    <!-- Bootstrap 5 JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
