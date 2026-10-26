<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
<jsp:include page="includes/header.jsp" />

<div class="auth-split-container">
    <div class="auth-split-card" style="max-width: 680px; grid-template-columns: 1fr; min-height: auto;">
        <div class="auth-split-form" style="padding: 40px; text-align: center;">
            <div class="mb-3">
                <span style="display: inline-flex; align-items: center; justify-content: center; width: 68px; height: 68px; border-radius: 50%; background-color: var(--color-danger-bg); color: var(--color-danger); border: 2px solid var(--color-danger); font-size: 1.8rem;">
                    <i class="fas fa-triangle-exclamation"></i>
                </span>
            </div>

            <h1 class="auth-split-title" style="font-size: 1.8rem; margin-bottom: 8px;">System Service Notice</h1>
            <p class="auth-split-subtitle" style="margin-bottom: 20px;">
                The application encountered an issue communicating with the database or completing your request.
            </p>

            <div class="card p-3 mb-4 text-start" style="background-color: var(--color-surface-muted); border: 1px solid var(--color-border); border-radius: 12px; font-family: var(--font-mono); font-size: 0.82rem;">
                <div class="d-flex align-items-center mb-1 text-danger fw-bold">
                    <i class="fas fa-database me-2"></i> Database Connection Status
                </div>
                <div class="text-muted">
                    If MySQL server is currently stopped on your machine, please start MySQL service via macOS System Settings or terminal:
                </div>
                <div class="p-2 mt-2" style="background: var(--color-surface); border: 1px solid var(--color-border); border-radius: 6px; font-weight: 600; color: var(--color-ink);">
                    sudo /usr/local/mysql/support-files/mysql.server start
                </div>
            </div>

            <div class="d-flex justify-content-center gap-3">
                <button type="button" onclick="window.location.reload();" class="auth-submit-btn" style="width: auto; padding: 10px 24px;">
                    <i class="fas fa-rotate me-2"></i> Try Again
                </button>
                <a href="<%= request.getContextPath() %>/" class="btn btn-outline-secondary" style="border-radius: 999px; padding: 10px 24px; font-weight: 600; border: 1.5px solid var(--color-border); color: var(--color-ink);">
                    <i class="fas fa-home me-2"></i> Homepage
                </a>
            </div>
        </div>
    </div>
</div>

<jsp:include page="includes/footer.jsp" />
