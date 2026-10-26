<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
<jsp:include page="includes/header.jsp" />

<div class="auth-split-container">
    <div class="auth-split-card" style="max-width: 600px; grid-template-columns: 1fr; min-height: auto;">
        <div class="auth-split-form" style="padding: 40px; text-align: center;">
            <div class="mb-3">
                <span style="display: inline-flex; align-items: center; justify-content: center; width: 68px; height: 68px; border-radius: 50%; background-color: var(--color-surface-muted); color: var(--color-ink); border: 2px solid var(--color-border); font-size: 1.8rem;">
                    <i class="fas fa-file-circle-question"></i>
                </span>
            </div>

            <h1 class="auth-split-title" style="font-size: 2rem; margin-bottom: 8px;">Page Not Found (404)</h1>
            <p class="auth-split-subtitle" style="margin-bottom: 24px;">
                The requested resource could not be found or has moved to a new URL.
            </p>

            <div class="d-flex justify-content-center gap-3">
                <a href="<%= request.getContextPath() %>/" class="auth-submit-btn" style="width: auto; padding: 10px 24px;">
                    <i class="fas fa-home me-2"></i> Return to Homepage
                </a>
            </div>
        </div>
    </div>
</div>

<jsp:include page="includes/footer.jsp" />
