<!-- Bootstrap 5 JS Bundle -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<!-- SweetAlert2 -->
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<!-- Chart.js -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<script>
(function() {
    const toggle = document.getElementById('sidebarToggle');
    const sidebar = document.getElementById('appSidebar');
    if (toggle && sidebar) {
        toggle.addEventListener('click', function() {
            sidebar.classList.toggle('open');
        });
        document.addEventListener('click', function(e) {
            if (sidebar.classList.contains('open') &&
                !sidebar.contains(e.target) && e.target !== toggle) {
                sidebar.classList.remove('open');
            }
        });
    }

    // Auto-dismiss alerts smoothly
    document.querySelectorAll('.alert:not(.alert-permanent)').forEach(function(el) {
        setTimeout(function() {
            el.style.transition = 'opacity 0.5s ease';
            el.style.opacity = '0';
            setTimeout(function() { el.remove(); }, 500);
        }, 5000);
    });
})();

// Global SweetAlert confirmation helper
function sweetConfirm(title, text, confirmText, callback) {
    Swal.fire({
        title: title || 'Are you sure?',
        text: text || '',
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#283f7d',
        cancelButtonColor: '#7d7d7d',
        confirmButtonText: confirmText || 'Yes, proceed',
        cancelButtonText: 'Cancel',
        reverseButtons: true
    }).then((result) => {
        if (result.isConfirmed) {
            callback();
        }
    });
}
</script>
</body>
</html>
