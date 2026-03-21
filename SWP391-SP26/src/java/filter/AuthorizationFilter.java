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

@WebFilter(filterName = "AuthorizationFilter", urlPatterns = { "/category" })
public class AuthorizationFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        HttpSession session = httpRequest.getSession(false);

        User user = (session != null) ? (User) session.getAttribute("acc") : null;

        if (user == null) {
            // Not logged in
            httpResponse.sendRedirect("login.jsp");
        } else {
            // Logged in, check role
            int roleId = user.getRoleID();
            // Role 1: Warehouse Staff, Role 2: Manager
            if (roleId == 1 || roleId == 2) {
                chain.doFilter(request, response);
            } else {
                // Not authorized (e.g., Admin or Sales)
                httpResponse.sendRedirect("login.jsp");
            }
        }
    }

    @Override
    public void destroy() {
    }
}
