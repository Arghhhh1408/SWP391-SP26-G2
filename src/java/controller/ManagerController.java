package controller;

import dao.CategoryDAO;
import dao.ReturnDAO;
import dao.WarrantyClaimDAO;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.ReturnStatus;
import model.User;
import model.WarrantyClaimStatus;

@WebServlet(name = "ManagerController", urlPatterns = {"/manager_dashboard"})
public class ManagerController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!ensureManager(request, response)) {
            return;
        }

        String tab = safeTrim(request.getParameter("tab"));
        if (tab == null || tab.isEmpty()) {
            tab = "overview";
        }
        request.setAttribute("tab", tab);

        if ("returns".equals(tab)) {
            ReturnDAO dao = new ReturnDAO();
            request.setAttribute("returns", dao.listAll());
        } else if ("warranty".equals(tab)) {
            WarrantyClaimDAO dao = new WarrantyClaimDAO();
            request.setAttribute("claims", dao.listAll());
        } else {
            // Dashboard Overview / Default
            WarrantyClaimDAO wDao = new WarrantyClaimDAO();
            ReturnDAO rDao = new ReturnDAO();
            CategoryDAO cDao = new CategoryDAO();
            
            var claims = wDao.listAll();
            var returns = rDao.listAll();
            
            request.setAttribute("totalClaims", claims.size());
            request.setAttribute("pendingClaims", claims.stream().filter(c -> "NEW".equals(c.getStatus().name())).count());
            
            request.setAttribute("totalReturns", returns.size());
            request.setAttribute("pendingReturns", returns.stream().filter(r -> "NEW".equals(r.getStatus().name())).count());
            
            request.setAttribute("recentClaims", claims.size() > 5 ? claims.subList(0, 5) : claims);
            
            // Load categories for the Add Product form
            try {
                request.setAttribute("categories", cDao.getAllCategories());
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        request.getRequestDispatcher("manager_dashboard.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!ensureManager(request, response)) {
            return;
        }

        String action = safeTrim(request.getParameter("action"));
        if (action == null || action.isEmpty()) {
            response.sendRedirect("manager_dashboard");
            return;
        }

        String actor = getActor(request);
        if ("confirmWarranty".equals(action)) {
            Integer id = tryParseInt(request.getParameter("id"));
            if (id != null) {
                WarrantyClaimDAO dao = new WarrantyClaimDAO();
                dao.updateStatus(id, WarrantyClaimStatus.APPROVED, "Manager xác nhận yêu cầu", actor);
            }
            response.sendRedirect("manager_dashboard?tab=warranty");
            return;
        }

        if ("rejectWarranty".equals(action)) {
            Integer id = tryParseInt(request.getParameter("id"));
            if (id != null) {
                WarrantyClaimDAO dao = new WarrantyClaimDAO();
                dao.updateStatus(id, WarrantyClaimStatus.REJECTED, "Manager từ chối yêu cầu", actor);
            }
            response.sendRedirect("manager_dashboard?tab=warranty");
            return;
        }
        
        if ("rejectWarranty".equals(action)) {
            Integer id = tryParseInt(request.getParameter("id"));
            if (id != null) {
                WarrantyClaimDAO dao = new WarrantyClaimDAO();
                dao.updateStatus(id, WarrantyClaimStatus.REJECTED, "Manager từ chối yêu cầu", actor);
            }
            response.sendRedirect("manager_dashboard?tab=warranty");
            return;
        }

        if ("confirmReturn".equals(action)) {
            Integer id = tryParseInt(request.getParameter("id"));
            if (id != null) {
                ReturnDAO dao = new ReturnDAO();
                dao.updateStatus(id, ReturnStatus.APPROVED, "Manager xác nhận yêu cầu", actor);
            }
            response.sendRedirect("manager_dashboard?tab=returns");
            return;
        }

        if ("rejectReturn".equals(action)) {
            Integer id = tryParseInt(request.getParameter("id"));
            if (id != null) {
                ReturnDAO dao = new ReturnDAO();
                dao.updateStatus(id, ReturnStatus.REJECTED, "Manager từ chối yêu cầu", actor);
            }
            response.sendRedirect("manager_dashboard?tab=returns");
            return;
        }
        
        if ("rejectReturn".equals(action)) {
            Integer id = tryParseInt(request.getParameter("id"));
            if (id != null) {
                ReturnDAO dao = new ReturnDAO();
                dao.updateStatus(id, ReturnStatus.REJECTED, "Manager từ chối yêu cầu", actor);
            }
            response.sendRedirect("manager_dashboard?tab=returns");
            return;
        }

        response.sendRedirect("manager_dashboard");
    }

    private boolean ensureManager(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession();
        User u = (User) session.getAttribute("acc");
        if (u == null || u.getRoleID() != 2) {
            response.sendRedirect("login");
            return false;
        }
        return true;
    }

    private Integer tryParseInt(String s) {
        try {
            return Integer.parseInt(s);
        } catch (Exception e) {
            return null;
        }
    }

    private String getActor(HttpServletRequest request) {
        HttpSession session = request.getSession();
        Object acc = session.getAttribute("acc");
        if (acc instanceof User u) {
            if (u.getUsername() != null && !u.getUsername().isBlank()) {
                return u.getUsername();
            }
            return "user#" + u.getUserID();
        }
        return "manager";
    }

    private String safeTrim(String s) {
        return s == null ? null : s.trim();
    }
}
