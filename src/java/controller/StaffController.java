/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

package controller;

import dao.CategoryDAO;
import dao.ReturnDAO;
import dao.WarrantyClaimDAO;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Product;
import model.ReturnStatus;
import model.User;
import model.WarrantyClaimStatus;

/**
 *
 * @author dotha
 */
@WebServlet(name="StaffController", urlPatterns={"/staff_dashboard"})
public class StaffController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!ensureStaff(request, response)) {
            return;
        }

        String tab = safeTrim(request.getParameter("tab"));
        if (tab == null || tab.isEmpty()) {
            tab = "warranty";
        }
        request.setAttribute("tab", tab);

        if ("returns".equals(tab)) {
            ReturnDAO dao = new ReturnDAO();
            request.setAttribute("returns", dao.listAll());
        } else if ("products".equals(tab)) {
            try {
                CategoryDAO dao = new CategoryDAO();
                List<Product> products = dao.getAllProducts();
                request.setAttribute("products", products);

                String editIdRaw = safeTrim(request.getParameter("editId"));
                Integer editId = tryParseInt(editIdRaw);
                if (editId != null) {
                    Product editProduct = dao.getProductById(editId);
                    if (editProduct != null) {
                        request.setAttribute("editProduct", editProduct);
                    }
                }
                request.setAttribute("categories", dao.getAllCategories());
            } catch (Exception e) {
                request.setAttribute("error", "Khong the tai danh sach san pham.");
            }
        } else {
            WarrantyClaimDAO dao = new WarrantyClaimDAO();
            request.setAttribute("claims", dao.listAll());
        }

        request.getRequestDispatcher("staff_dashboard.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!ensureStaff(request, response)) {
            return;
        }

        String action = safeTrim(request.getParameter("action"));
        if ("completeWarranty".equals(action)) {
            Integer id = tryParseInt(request.getParameter("id"));
            if (id != null) {
                WarrantyClaimDAO dao = new WarrantyClaimDAO();
                dao.updateStatus(id, WarrantyClaimStatus.COMPLETED, "Staff xác nhận đã bảo hành", getActor(request));
            }
            response.sendRedirect("staff_dashboard?tab=warranty");
            return;
        }
        
        if ("rejectWarranty".equals(action)) {
            Integer id = tryParseInt(request.getParameter("id"));
            if (id != null) {
                WarrantyClaimDAO dao = new WarrantyClaimDAO();
                dao.updateStatus(id, WarrantyClaimStatus.REJECTED, "Staff từ chối yêu cầu bảo hành", getActor(request));
            }
            response.sendRedirect("staff_dashboard?tab=warranty");
            return;
        }

        if ("completeReturn".equals(action)) {
            Integer id = tryParseInt(request.getParameter("id"));
            if (id != null) {
                ReturnDAO dao = new ReturnDAO();
                dao.updateStatus(id, ReturnStatus.COMPLETED, "Staff xác nhận đã trả hàng", getActor(request));
            }
            response.sendRedirect("staff_dashboard?tab=returns");
            return;
        }
        
        if ("rejectReturn".equals(action)) {
            Integer id = tryParseInt(request.getParameter("id"));
            if (id != null) {
                ReturnDAO dao = new ReturnDAO();
                dao.updateStatus(id, ReturnStatus.REJECTED, "Staff từ chối yêu cầu trả hàng", getActor(request));
            }
            response.sendRedirect("staff_dashboard?tab=returns");
            return;
        }

        response.sendRedirect("staff_dashboard");
    }

    private boolean ensureStaff(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession();
        User u = (User) session.getAttribute("acc");
        if (u == null || u.getRoleID() != 1) {
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
        return "staff";
    }

    private String safeTrim(String s) {
        return s == null ? null : s.trim();
    }
}
