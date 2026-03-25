/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dao.SupplierDAO;
import dao.NotificationDAO;
import dao.SystemLogDAO;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Notification;
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

        if (u == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");
        String idStr = request.getParameter("id");

        if ("delete".equals(action) && u.getRoleID() != 2) {
            request.setAttribute("message", "Bạn không có quyền ngừng hoạt động nhà cung cấp.");
            request.getRequestDispatcher("supplierList").forward(request, response);
            return;
        }

        if (("add".equals(action) || "edit".equals(action)) && u.getRoleID() != 2) {
            request.setAttribute("message", "Bạn không có quyền thực hiện chức năng này.");
            request.getRequestDispatcher("supplierList").forward(request, response);
            return;
        }

        if ("delete".equals(action) && idStr != null) {
            try {
                int id = Integer.parseInt(idStr);
                Supplier s = dao.getSupplierById(id);
                boolean ok = dao.deactivateSupplier(id);

                if (ok) {
                    session.setAttribute("message", "Ngừng hoạt động nhà cung cấp thành công!");
                    session.setAttribute("status", "success");

                    SystemLogDAO logDao = new SystemLogDAO();
                    SystemLog log = new SystemLog();
                    log.setUserID(u.getUserID());
                    log.setAction("DEACTIVATE_SUPPLIER");
                    log.setTargetObject("Supplier ID: " + id);
                    String sName = (s != null) ? s.getSupplierName() : "Unknown";
                    log.setDescription("Ngừng hoạt động nhà cung cấp: " + sName + " (ID: " + id + ")");
                    log.setIpAddress(request.getRemoteAddr());
                    logDao.insertLog(log);
                } else {
                    session.setAttribute("message", "Không tìm thấy nhà cung cấp để cập nhật trạng thái!");
                    session.setAttribute("status", "error");
                }

            } catch (NumberFormatException e) {
                session.setAttribute("message", "Lỗi định dạng ID: " + e.getMessage());
                session.setAttribute("status", "error");
            } catch (Exception e) {
                session.setAttribute("message", "Lỗi xử lý nhà cung cấp: " + e.getMessage());
                session.setAttribute("status", "error");
            }

            response.sendRedirect(request.getContextPath() + "/supplierList");
            return;
        }

        if ("add".equals(action)) {
            request.getRequestDispatcher("addsupplierform.jsp").forward(request, response);
            return;
        }

        if ("edit".equals(action) && idStr != null) {
            try {
                int id = Integer.parseInt(idStr);
                Supplier supplier = dao.getSupplierById(id);
                if (supplier != null) {
                    request.setAttribute("supplier", supplier);
                } else {
                    request.setAttribute("error", "Không tìm thấy nhà cung cấp!");
                }
            } catch (NumberFormatException e) {
                request.setAttribute("error", "Lỗi định dạng ID: " + e.getMessage());
            } catch (Exception e) {
                request.setAttribute("error", "Lỗi tải nhà cung cấp: " + e.getMessage());
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

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("acc") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        User user = (User) session.getAttribute("acc");
        if (user == null || user.getRoleID() != 2) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");
        String message = "";
        String status = "";

        try {
            if ("addSupplier".equals(action)) {
                String name = request.getParameter("supplierName");
                String phone = request.getParameter("phone");
                String address = request.getParameter("address");
                String email = request.getParameter("email");

                if (!ValidationUtils.isValidPhone(phone)) {
                    message = "Số điện thoại không hợp lệ!";
                    status = "error";
                } else if (!ValidationUtils.isValidEmail(email)) {
                    message = "Email không hợp lệ!";
                    status = "error";
                } else {
                    String error = dao.checkDuplicate(name, email, phone);
                    if (error != null) {
                        message = error;
                        status = "error";
                    } else {
                        boolean ok = dao.addSupplier(name, phone, address, email);
                        if (ok) {
                            message = "Thêm nhà cung cấp thành công!";
                            status = "success";

                            SystemLogDAO logDao = new SystemLogDAO();
                            SystemLog log = new SystemLog();
                            log.setUserID(user.getUserID());
                            log.setAction("CREATE_SUPPLIER");
                            log.setTargetObject("Supplier: " + name);
                            log.setDescription("Thêm nhà cung cấp mới: " + name);
                            log.setIpAddress(request.getRemoteAddr());
                            logDao.insertLog(log);

                            // Notify staff
                            NotificationDAO nDao = new NotificationDAO();
                            String notifMessage = "Manager Đã thêm 1 nhà cung cấp | tên nhà cung cấp: " + name;
                            List<Integer> staffIds = nDao.getStaffIds();
                            for (int staffId : staffIds) {
                                Notification n = new Notification();
                                n.setUserId(staffId);
                                n.setTitle("Nhà cung cấp mới");
                                n.setMessage(notifMessage);
                                n.setType("SUPPLIER_ADDED");
                                nDao.insert(n);
                            }
                        } else {
                            message = "Thêm nhà cung cấp thất bại!";
                            status = "error";
                        }
                    }
                }

            } else if ("updateSupplier".equals(action)) {
                int id = Integer.parseInt(request.getParameter("supplierID"));
                String newName = request.getParameter("supplierName");
                String newPhone = request.getParameter("phone");
                String newAddress = request.getParameter("address");
                String newEmail = request.getParameter("email");
                boolean newStatus = request.getParameter("status") != null;

                if (!ValidationUtils.isValidPhone(newPhone)) {
                    message = "Số điện thoại không hợp lệ!";
                    status = "error";
                } else if (!ValidationUtils.isValidEmail(newEmail)) {
                    message = "Email không hợp lệ!";
                    status = "error";
                } else {
                    Supplier oldSupplier = dao.getSupplierById(id);
                    if (oldSupplier == null) {
                        message = "Không tìm thấy nhà cung cấp!";
                        status = "error";
                    } else {
                        String duplicateError = dao.checkDuplicateForUpdate(id, newName, newEmail, newPhone);
                        if (duplicateError != null) {
                            message = duplicateError;
                            status = "error";
                        } else {
                            boolean ok = dao.updateSupplier(id, newName, newPhone, newEmail, newAddress, newStatus);
                            if (ok) {
                                message = "Cập nhật nhà cung cấp thành công!";
                                status = "success";

                                SystemLogDAO logDAO = new SystemLogDAO();
                                SystemLog log = new SystemLog();
                                log.setUserID(user.getUserID());
                                log.setAction("UPDATE_SUPPLIER");
                                log.setTargetObject("Supplier ID: " + id);
                                log.setDescription("Cập nhật thông tin nhà cung cấp: " + newName + " (ID: " + id + ")");
                                log.setIpAddress(request.getRemoteAddr());
                                logDAO.insertLog(log);
                            } else {
                                message = "Cập nhật nhà cung cấp thất bại!";
                                status = "error";
                            }
                        }
                    }
                }

            } else {
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
