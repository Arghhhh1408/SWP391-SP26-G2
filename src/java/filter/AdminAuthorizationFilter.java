package filter;

import java.io.IOException;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;

@WebFilter(filterName = "AdminAuthorizationFilter", urlPatterns = {
    "/admin", "/admin.jsp", "/adminSidebar.jsp",
    "/userList", "/userList.jsp", 
    "/createUser", "/addUser.jsp",
    "/deleteUser",
    "/updateuser", "/userDetail.jsp",
    "/systemlog", "/systemLog.jsp", "/systemlog.jsp",
    "/deletedUsers", "/deletedUsers.jsp",
    "/lockedUsers", "/lockedUsers.jsp",
    "/restoreUser",
    "/unlockUser",
    "/notification_admin.jsp"
})
public class AdminAuthorizationFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // Initialization code if needed
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        HttpSession session = httpRequest.getSession(false);

        User user = (session != null) ? (User) session.getAttribute("acc") : null;

        // Ensure user is logged in and has roleID == 0 (Admin)
        if (user == null || user.getRoleID() != 0) {
            httpResponse.sendRedirect(httpRequest.getContextPath() + "/login");
            return;
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
        // Cleanup code if needed
    }
}
