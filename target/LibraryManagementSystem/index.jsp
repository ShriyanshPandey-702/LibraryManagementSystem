<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:include page="jsp/includes/header.jsp" />

<style>
    .hero-section {
        background: linear-gradient(rgba(43, 45, 66, 0.8), rgba(43, 45, 66, 0.8)), url('https://images.unsplash.com/photo-1507842217343-583bb7270b66?ixlib=rb-4.0.3&auto=format&fit=crop&w=2000&q=80') center/cover;
        color: white;
        padding: 100px 0;
        min-height: 100vh;
        display: flex;
        align-items: center;
    }
    .feature-icon {
        font-size: 3rem;
        color: var(--primary-color);
        margin-bottom: 1rem;
    }
    .landing-card {
        background: rgba(255, 255, 255, 0.1);
        backdrop-filter: blur(10px);
        border: 1px solid rgba(255, 255, 255, 0.2);
        border-radius: 15px;
        padding: 3rem;
        text-align: center;
        transition: transform 0.3s;
    }
    .landing-card:hover {
        transform: translateY(-10px);
    }
</style>

<div class="hero-section">
    <div class="container">
        <div class="row align-items-center">
            <div class="col-lg-6 mb-5 mb-lg-0 text-center text-lg-start">
                <h1 class="display-4 fw-bold mb-4">Modern Library<br><span class="text-info">Management System</span></h1>
                <p class="lead mb-5 opacity-75">Streamline your library operations with our industry-standard digital solution. Issue books, track fines, and manage students seamlessly.</p>
                <div class="d-flex flex-column flex-sm-row gap-3 justify-content-center justify-content-lg-start">
                    <a href="#login-section" class="btn btn-info btn-lg px-5 py-3 rounded-pill fw-bold text-white shadow-sm">Get Started</a>
                    <a href="#features" class="btn btn-outline-light btn-lg px-5 py-3 rounded-pill fw-bold">Explore Features</a>
                </div>
            </div>
            <div class="col-lg-6" id="login-section">
                <div class="row g-4">
                    <div class="col-md-6">
                        <div class="landing-card h-100">
                            <i class="fas fa-user-shield feature-icon text-white mb-3"></i>
                            <h3 class="h4 fw-bold mb-3">Admin Portal</h3>
                            <p class="opacity-75 mb-4">Manage books, approve requests, and oversee operations.</p>
                            <a href="${pageContext.request.contextPath}/LoginServlet" class="btn btn-light w-100 fw-bold text-primary">Admin Login</a>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="landing-card h-100">
                            <i class="fas fa-user-graduate feature-icon text-white mb-3"></i>
                            <h3 class="h4 fw-bold mb-3">Student Portal</h3>
                            <p class="opacity-75 mb-4">Browse catalog, request books, and check fine status.</p>
                            <a href="${pageContext.request.contextPath}/StudentLoginServlet" class="btn btn-info w-100 fw-bold text-white">Student Login</a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<section id="features" class="py-5 bg-white">
    <div class="container py-5">
        <div class="text-center mb-5">
            <h2 class="fw-bold">Key Features</h2>
            <p class="text-muted">Everything you need for a modern digital library.</p>
        </div>
        <div class="row g-4 text-center">
            <div class="col-md-4">
                <div class="p-4">
                    <i class="fas fa-book feature-icon"></i>
                    <h4 class="fw-bold">Digital Catalog</h4>
                    <p class="text-muted">Search and explore our entire collection of books easily online.</p>
                </div>
            </div>
            <div class="col-md-4">
                <div class="p-4">
                    <i class="fas fa-clock feature-icon"></i>
                    <h4 class="fw-bold">Automated Fines</h4>
                    <p class="text-muted">System automatically calculates fines for overdue book returns.</p>
                </div>
            </div>
            <div class="col-md-4">
                <div class="p-4">
                    <i class="fas fa-bell feature-icon"></i>
                    <h4 class="fw-bold">Book Requests</h4>
                    <p class="text-muted">Students can request books directly from their dashboard seamlessly.</p>
                </div>
            </div>
        </div>
    </div>
</section>

<jsp:include page="jsp/includes/footer.jsp" />
