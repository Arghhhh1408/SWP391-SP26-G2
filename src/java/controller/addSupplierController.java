/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dao.SupplierDAO;
import dao.SystemLogDAO;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Supplier;
import model.SystemLog;
import model.User;
import utils.ValidationUtils;

/**
 *
 * @author dotha
 */
@WebServlet(name = "addSupplierController", urlPatterns = {"/addSupplier"})
public class addSupplierController extends HttpServlet {

    private SupplierDAO dao;

    @Override
    public void init() throws ServletException {
        dao = new SupplierDAO();
    }

    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User u = (User) session.getAttribute("acc");
        if (u == null || u.getRoleID() != 2) {
            request.setAttribute("message", "Chỉ có quản lý mới được thêm mới nhà cung cấp.");
            request.getRequestDispatcher("supplierList").forward(request, response);
            return;
        }
        String action = request.getParameter("action");
        String idStr = request.getParameter("id");
        if ("delete".equals(action) && idStr != null) {
            try {
                int id = Integer.parseInt(idStr);
                dao.deleteSupplier(id);
                session.setAttribute("message", "Xóa nhà cung cấp thành công!");
                session.setAttribute("status", "success");
                SystemLogDAO logDao = new SystemLogDAO();
                SystemLog log = new SystemLog();
                int userID = (u != null) ? u.getUserID() : 2;
                log.setUserID(userID);
                log.setAction("DELETE_SUPPLIER");
                log.setTargetObject("Supplier ID: " + id);
                log.setDescription("Deleted supplier");
                log.setIpAddress(request.getRemoteAddr());
                logDao.insertLog(log);
            } catch (NumberFormatException e) {
                session.setAttribute("message", "Lỗi định dạng ID: " + e.getMessage());
                session.setAttribute("status", "error");
            } catch (Exception e) {
                session.setAttribute("message", "Lỗi xóa nhà cung cấp: " + e.getMessage());
                session.setAttribute("status", "error");
            }
            response.sendRedirect(request.getContextPath() + "/supplierList");
            return;
        } else if ("add".equals(action)) {
            request.getRequestDispatcher("addsupplierform.jsp").forward(request, response);
            return;
        } else if ("edit".equals(action) && idStr != null) {
            try {
                int id = Integer.parseInt(idStr);
                Supplier supplier = dao.getSupplierById(id);
                if (supplier != null) {
                    request.setAttribute("supplier", supplier);
                    request.setAttribute("mode", "edit");
                } else {
                    request.setAttribute("error", "Không tìm thấy nhà cung cấp!");
                }
            } catch (NumberFormatException e) {
                request.setAttribute("error", "Lỗi định dạng ID: " + e.getMessage());
            } catch (Exception e) {
                request.setAttribute("error", "Lỗi load nhà cung cấp: " + e.getMessage());
            }
            request.getRequestDispatcher("addsupplierform.jsp").forward(request, response);
            return;
        }
        response.sendRedirect(request.getContextPath() + "/supplierList");
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        User u = (User) session.getAttribute("acc");
        if (u == null || u.getRoleID() != 2) {  // Sửa điều kiện check manager
            request.setAttribute("message", "Chỉ Warehouse Staff hoặc Quản lý mới được tạo phiếu nhập.");
            request.getRequestDispatcher("stockinList").forward(request, response);
            return;
        }
        String action = request.getParameter("action");
        if (action == null) {
            action = "";
        }
        String message = "";
        String status = "";
        try {
            switch (action) {
                case "addSupplier": {
                    String name = request.getParameter("supplierName");
                    String phone = request.getParameter("phone");
                    String address = request.getParameter("address");
                    String email = request.getParameter("email");
                    if (!ValidationUtils.isValidPhone(phone)) {
                        message = "Invalid phone number format! Must be 10 digits starting with 03, 07, 08, 09.";
                        status = "error";
                        break;
                    }
                    if (!ValidationUtils.isValidEmail(email)) {
                        message = "Invalid email format!";
                        status = "error";
                        break;
                    }
                    String error = dao.checkDuplicate(name, email, phone);
                    if (error != null) {
                        message = error;
                        status = "error";
                        break;
                    }
                    dao.addSupplier(name, phone, address, email);
                    message = "Thêm nhà cung cấp thành công";
                    status = "success";
                    SystemLogDAO logDao = new SystemLogDAO();
                    SystemLog log = new SystemLog();
                    int userID = (u != null) ? u.getUserID() : 2;
                    log.setUserID(userID);
                    log.setAction("CREATE_SUPPLIER");
                    log.setTargetObject("New Supplier: " + name);
                    log.setDescription("Created new supplier");
                    log.setIpAddress(request.getRemoteAddr());
                    logDao.insertLog(log);
                    break;
                }
                case "updateSupplier": {
                    int id = Integer.parseInt(request.getParameter("supplierID"));
                    String newName = request.getParameter("supplierName");
                    String newPhone = request.getParameter("phone");
                    String newAddress = request.getParameter("address");
                    String newEmail = request.getParameter("email");
                    boolean newStatus = request.getParameter("status") != null;
                    if (!ValidationUtils.isValidEmail(newEmail)) {
                        message = "Invalid email format!";
                        status = "error";
                        break;
                    }
                    if (!ValidationUtils.isValidPhone(newPhone)) {
                        message = "Invalid phone number format! Must be 10 digits starting with 03, 07, 08, 09.";
                        status = "error";
                        break;
                    }
                    Supplier oldSupplier = dao.getSupplierById(id);
                    String duplicateError = dao.checkDuplicateForUpdate(id, newName, newEmail, newPhone);
                    if (duplicateError != null) {
                        message = duplicateError;
                        status = "error";
                        break;
                    }
                    if (oldSupplier == null) {
                        message = "Không tìm thấy nhà cung cấp!";
                        status = "error";
                        break;
                    } else {
                        dao.updateSupplier(id, newName, newPhone, newEmail, newAddress, newStatus);
                        StringBuilder changes = new StringBuilder("Cập nhật nhà cung cấp thành công! Các thay đổi: ");
                        if (!oldSupplier.getSupplierName().equals(newName)) {
                            changes.append("Tên: ").append(oldSupplier.getSupplierName()).append("-> ").append(newName).append(";");
                        }
                        if (!oldSupplier.getPhone().equals(newPhone)) {
                            changes.append("SĐT: ").append(oldSupplier.getPhone()).append("-> ").append(newPhone).append(";");
                        }
                        if ((oldSupplier.getAddress() == null ? newAddress != null : !oldSupplier.getAddress().equals(newAddress))) {
                            changes.append("Địa chỉ: ").append(oldSupplier.getAddress()).append("-> ").append(newAddress).append(";");
                        }
                        if ((oldSupplier.getEmail() == null ? newEmail != null : !oldSupplier.getEmail().equals(newEmail))) {
                            changes.append("Email: ").append(oldSupplier.getEmail()).append("-> ").append(newEmail).append(";");
                        }
                        if (oldSupplier.isStatus() != newStatus) {
                            changes.append("Trạng thái: ").append(oldSupplier.isStatus() ? "Hoạt động" : "Ngừng")
                                    .append("-> ").append(newStatus ? "Hoạt động" : "Ngừng").append(";");
                        }
                        if (changes.toString().endsWith("Các thay đổi: ")) {
                            changes.append("Không có thay đổi nào!");
                        }
                        message = changes.toString();
                        status = "success";
                        SystemLogDAO logDAO = new SystemLogDAO();
                        SystemLog log = new SystemLog();
                        int userID = (u != null) ? u.getUserID() : 2;
                        log.setUserID(userID);
                        log.setAction("UPDATE_SUPPLIER");
                        log.setTargetObject("Supplier ID: " + id);
                        log.setDescription(changes.toString());
                        log.setIpAddress(request.getRemoteAddr());
                        logDAO.insertLog(log);
                    }
                    break;
                }
                default:
                    message = "Hành động không hợp lệ!";
                    status = "error";
            }
        } catch (NumberFormatException e) {
            message = "Lỗi định dạng số: " + e.getMessage();
            status = "error";
        } catch (Exception e) {
            message = "Lỗi: " + e.getMessage();
            status = "error";
        }
        session.setAttribute("message", message);
        session.setAttribute("status", status);
        response.sendRedirect(request.getContextPath() + "/supplierList");
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }
}
