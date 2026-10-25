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

    // Theme Toggle Functionality
    const themeBtn = document.getElementById('themeToggleBtn');
    function updateThemeIcon() {
        const isDark = document.documentElement.getAttribute('data-theme') === 'dark';
        if (themeBtn) {
            themeBtn.innerHTML = isDark ? '<i class="fas fa-sun"></i>' : '<i class="fas fa-moon"></i>';
            themeBtn.setAttribute('title', isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode');
        }
    }
    updateThemeIcon();

    if (themeBtn) {
        themeBtn.addEventListener('click', function() {
            const current = document.documentElement.getAttribute('data-theme') === 'dark' ? 'dark' : 'light';
            const next = current === 'dark' ? 'light' : 'dark';
            document.documentElement.setAttribute('data-theme', next);
            localStorage.setItem('libris_theme', next);
            updateThemeIcon();
        });
    }

    // Notifications System
    const notifBell = document.getElementById('notifBellBtn');
    const notifBadge = document.getElementById('notifBadge');
    const notifDropdown = document.getElementById('notifDropdown');
    const notifList = document.getElementById('notifList');
    const markAllRead = document.getElementById('markAllReadBtn');
    const ctx = window.LIBRIS_CTX || '';

    function loadNotifications() {
        if (!notifBell) return;
        fetch(ctx + '/NotificationServlet')
            .then(res => {
                if (!res.ok) throw new Error('Not logged in or error');
                return res.json();
            })
            .then(data => {
                if (data.unreadCount > 0) {
                    notifBadge.textContent = data.unreadCount;
                    notifBadge.classList.remove('d-none');
                } else {
                    notifBadge.classList.add('d-none');
                }

                if (!data.notifications || data.notifications.length === 0) {
                    notifList.innerHTML = '<div class="p-3 text-center text-muted small">No notifications yet.</div>';
                    return;
                }

                let html = '';
                data.notifications.forEach(n => {
                    const icon = n.type === 'alert' ? 'fa-triangle-exclamation text-warning' :
                                 n.type === 'overdue' ? 'fa-circle-exclamation text-danger' :
                                 n.type === 'success' ? 'fa-circle-check text-success' : 'fa-bell text-accent';
                    const unreadClass = n.isRead ? '' : 'unread';
                    const linkAttr = n.link ? n.link : '';
                    html += '<div class="notif-item ' + unreadClass + '" data-id="' + n.id + '" data-link="' + linkAttr + '">' +
                            '<div class="d-flex align-items-start gap-2">' +
                            '<i class="fas ' + icon + ' mt-1"></i>' +
                            '<div class="flex-grow-1">' +
                            '<div class="notif-item-title">' + escapeHtml(n.title) + '</div>' +
                            '<div class="notif-item-msg">' + escapeHtml(n.message) + '</div>' +
                            '<div class="notif-item-time">' + formatDate(n.createdAt) + '</div>' +
                            '</div></div></div>';
                });
                notifList.innerHTML = html;

                // Click event on items
                notifList.querySelectorAll('.notif-item').forEach(item => {
                    item.addEventListener('click', function() {
                        const id = this.getAttribute('data-id');
                        const link = this.getAttribute('data-link');
                        if (this.classList.contains('unread')) {
                            fetch(ctx + '/NotificationServlet?action=markRead&id=' + id, { method: 'POST' });
                            this.classList.remove('unread');
                            let count = parseInt(notifBadge.textContent || '1') - 1;
                            if (count <= 0) notifBadge.classList.add('d-none');
                            else notifBadge.textContent = count;
                        }
                        if (link && link.trim() !== '') {
                            window.location.href = ctx + '/' + link.replace(/^\//, '');
                        }
                    });
                });
            })
            .catch(() => {
                // Silently ignore if unauthenticated or network issue
            });
    }

    if (notifBell && notifDropdown) {
        notifBell.addEventListener('click', function(e) {
            e.stopPropagation();
            notifDropdown.classList.toggle('show');
            if (notifDropdown.classList.contains('show')) {
                loadNotifications();
            }
        });

        document.addEventListener('click', function(e) {
            if (!notifDropdown.contains(e.target) && e.target !== notifBell) {
                notifDropdown.classList.remove('show');
            }
        });

        if (markAllRead) {
            markAllRead.addEventListener('click', function() {
                fetch(ctx + '/NotificationServlet?action=markAllRead', { method: 'POST' })
                    .then(() => {
                        notifBadge.classList.add('d-none');
                        notifList.querySelectorAll('.notif-item.unread').forEach(el => el.classList.remove('unread'));
                    });
            });
        }

        // Initial load & periodic poll
        loadNotifications();
        setInterval(loadNotifications, 60000);
    }

    function escapeHtml(str) {
        if (!str) return '';
        const d = document.createElement('div');
        d.textContent = str;
        return d.innerHTML;
    }

    function formatDate(dt) {
        if (!dt) return '';
        return dt.replace('T', ' ').substring(0, 16);
    }
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
