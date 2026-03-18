/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dao.InventoryCheckDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.sql.Date;
import java.util.List;
import model.InventoryCheckItem;

/**
 *
 * @author dotha
 */
@WebServlet(name = "InventoryCheckController", urlPatterns = {"/inventoryCheck"})
public class InventoryCheckController extends HttpServlet {

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet InventoryCheckController</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet InventoryCheckController at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
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

        request.setCharacterEncoding("UTF-8");

        String mode = request.getParameter("mode");
        InventoryCheckDAO dao = new InventoryCheckDAO();

        if ("view".equals(mode)) {
            handleView(request, response, dao);
            return;
        }

        if ("edit".equals(mode)) {
            handleEditForm(request, response, dao);
            return;
        }

        String keyword = request.getParameter("keyword");

        List<InventoryCheckItem> items = dao.searchProductsForCounting(keyword);

        InventoryCheckDAO dao2 = new InventoryCheckDAO();
        List<InventoryCheckItem> checkedItems = dao2.getLatestInventoryCountsByProduct();

        request.setAttribute("keyword", keyword);
        request.setAttribute("items", items);
        request.setAttribute("checkedItems", checkedItems);
        request.getRequestDispatcher("inventoryCheck.jsp").forward(request, response);
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

        String action = request.getParameter("action");
        String keyword = request.getParameter("keyword");
        String[] productIds = request.getParameterValues("productId");

        List<InventoryCheckItem> items = new ArrayList<>();
        List<String> errors = new ArrayList<>();

        if (productIds != null) {
            for (String pidRaw : productIds) {
                try {
                    int productId = Integer.parseInt(pidRaw);
                    int systemQuantity = Integer.parseInt(request.getParameter("systemQuantity_" + productId));

                    String physicalRaw = request.getParameter("physicalQuantity_" + productId);
                    Integer physicalQuantity = null;

                    if (physicalRaw != null && !physicalRaw.trim().isEmpty()) {
                        physicalQuantity = Integer.parseInt(physicalRaw.trim());

                        if (physicalQuantity < 0) {
                            errors.add("Số lượng thực tế không được âm ở sản phẩm ID " + productId);
                            continue;
                        }
                    }

                    InventoryCheckItem item = new InventoryCheckItem();
                    item.setProductId(productId);
                    item.setSku(request.getParameter("sku_" + productId));
                    item.setProductName(request.getParameter("productName_" + productId));
                    item.setUnit(request.getParameter("unit_" + productId));
                    item.setSystemQuantity(systemQuantity);
                    item.setPhysicalQuantity(physicalQuantity);

                    int variance = 0;
                    if (physicalQuantity != null) {
                        variance = physicalQuantity - systemQuantity;
                    }
                    item.setVariance(variance);

                    item.setStatus("Pending");

                    items.add(item);

                } catch (NumberFormatException e) {
                    errors.add("Dữ liệu nhập không hợp lệ.");
                } catch (Exception e) {
                    errors.add("Có lỗi xảy ra khi xử lý dữ liệu.");
                }
            }
        }

        if ("calculate".equals(action)) {
            InventoryCheckDAO dao = new InventoryCheckDAO();
            List<InventoryCheckItem> checkedItems = dao.getLatestInventoryCountsByProduct();

            request.setAttribute("keyword", keyword);
            request.setAttribute("items", items);
            request.setAttribute("checkedItems", checkedItems);
            request.setAttribute("errors", errors);
            request.getRequestDispatcher("inventoryCheck.jsp").forward(request, response);
            return;
        }

        if ("save".equals(action)) {
            boolean hasAtLeastOneInput = false;
            for (InventoryCheckItem item : items) {
                if (item.getPhysicalQuantity() != null) {
                    hasAtLeastOneInput = true;
                    break;
                }
            }

            if (!errors.isEmpty()) {
                InventoryCheckDAO dao = new InventoryCheckDAO();
                List<InventoryCheckItem> checkedItems = dao.getLatestInventoryCountsByProduct();

                request.setAttribute("keyword", keyword);
                request.setAttribute("items", items);
                request.setAttribute("checkedItems", checkedItems);
                request.setAttribute("errors", errors);
                request.getRequestDispatcher("inventoryCheck.jsp").forward(request, response);
                return;
            }

            if (!hasAtLeastOneInput) {
                InventoryCheckDAO dao = new InventoryCheckDAO();
                List<InventoryCheckItem> checkedItems = dao.getLatestInventoryCountsByProduct();

                request.setAttribute("keyword", keyword);
                request.setAttribute("items", items);
                request.setAttribute("checkedItems", checkedItems);
                request.setAttribute("error", "Bạn chưa nhập số lượng thực tế cho sản phẩm nào.");
                request.getRequestDispatcher("inventoryCheck.jsp").forward(request, response);
                return;
            }

            InventoryCheckDAO dao = new InventoryCheckDAO();
            boolean ok = dao.saveInventoryCounts(items);

            if (ok) {
                request.getSession().setAttribute("message", "Lưu kiểm kê thành công.");
            } else {
                request.getSession().setAttribute("error", "Lưu kiểm kê thất bại.");
            }

            String encodedKeyword = keyword == null ? "" : URLEncoder.encode(keyword, "UTF-8");
            response.sendRedirect("inventoryCheck?keyword=" + encodedKeyword);
        }
    }
    
    private void handleView(HttpServletRequest request, HttpServletResponse response, InventoryCheckDAO dao)
            throws ServletException, IOException {

        String idRaw = request.getParameter("id");

        try {
            int countId = Integer.parseInt(idRaw);
            InventoryCheckItem item = dao.getInventoryCountById(countId);

            if (item == null) {
                request.getSession().setAttribute("error", "Không tìm thấy bản ghi kiểm kê.");
                response.sendRedirect("inventoryCheck");
                return;
            }

            request.setAttribute("item", item);
            request.getRequestDispatcher("inventoryCheckDetail.jsp").forward(request, response);

        } catch (Exception e) {
            request.getSession().setAttribute("error", "Dữ liệu không hợp lệ.");
            response.sendRedirect("inventoryCheck");
        }
    }

    private void handleEditForm(HttpServletRequest request, HttpServletResponse response, InventoryCheckDAO dao)
            throws ServletException, IOException {

        String idRaw = request.getParameter("id");

        try {
            int countId = Integer.parseInt(idRaw);
            InventoryCheckItem item = dao.getInventoryCountById(countId);

            if (item == null) {
                request.getSession().setAttribute("error", "Không tìm thấy bản ghi cần sửa.");
                response.sendRedirect("inventoryCheck");
                return;
            }

            request.setAttribute("item", item);
            request.getRequestDispatcher("inventoryCheckEdit.jsp").forward(request, response);

        } catch (Exception e) {
            request.getSession().setAttribute("error", "Dữ liệu không hợp lệ.");
            response.sendRedirect("inventoryCheck");
        }
    }

    private void handleUpdate(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            int countId = Integer.parseInt(request.getParameter("countId"));
            int systemQuantity = Integer.parseInt(request.getParameter("systemQuantity"));
            int physicalQuantity = Integer.parseInt(request.getParameter("physicalQuantity"));
            String status = request.getParameter("status");

            InventoryCheckDAO dao = new InventoryCheckDAO();
            InventoryCheckItem oldItem = dao.getInventoryCountById(countId);

            if (oldItem == null) {
                request.getSession().setAttribute("error", "Không tìm thấy bản ghi cần cập nhật.");
                response.sendRedirect("inventoryCheck");
                return;
            }

            if (physicalQuantity < 0) {
                request.setAttribute("error", "Số lượng thực tế không được âm.");
                request.setAttribute("item", oldItem);
                request.getRequestDispatcher("inventoryCheckEdit.jsp").forward(request, response);
                return;
            }

            InventoryCheckItem item = new InventoryCheckItem();
            item.setCountId(countId);
            item.setSystemQuantity(systemQuantity);
            item.setPhysicalQuantity(physicalQuantity);
            item.setStatus(status);
            item.setDate(new Date(System.currentTimeMillis()));

            boolean ok = dao.updateInventoryCount(item);

            if (ok) {
                request.getSession().setAttribute("message", "Cập nhật kiểm kê thành công.");
            } else {
                request.getSession().setAttribute("error", "Cập nhật kiểm kê thất bại.");
            }

            response.sendRedirect("inventoryCheck");

        } catch (Exception e) {
            request.getSession().setAttribute("error", "Dữ liệu cập nhật không hợp lệ.");
            response.sendRedirect("inventoryCheck");
        }
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
