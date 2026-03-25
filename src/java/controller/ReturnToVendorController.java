/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dao.ReturnToVendorDAO;
import dao.StockInDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import model.ReturnToVendor;
import model.ReturnToVendorDetail;
import model.StockInDetail;
import model.User;

/**
 *
 * @author dotha
 */
@WebServlet(name = "ReturnToVendorController", urlPatterns = {"/return-to-vendor"})
public class ReturnToVendorController extends HttpServlet {

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
            out.println("<title>Servlet ReturnToVendorController</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet ReturnToVendorController at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

    private String generateReturnCode() {
        return "RTV-" + System.currentTimeMillis();
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

        HttpSession session = request.getSession();
        User acc = (User) session.getAttribute("acc");

        if (acc == null) {
            response.sendRedirect("login");
            return;
        }

        ReturnToVendorDAO dao = new ReturnToVendorDAO();
        String action = request.getParameter("action");

        try {
            if ("create".equals(action)) {
                request.getRequestDispatcher("returnToVendorCreate.jsp").forward(request, response);
                return;
            }

            if ("detail".equals(action)) {
                int rtvID = Integer.parseInt(request.getParameter("id"));
                ReturnToVendor rtv = dao.getById(rtvID);
                request.setAttribute("rtv", rtv);
                request.getRequestDispatcher("returnToVendorDetail.jsp").forward(request, response);
                return;
            }

            request.setAttribute("list", dao.getAllReturns());
            request.getRequestDispatcher("returnToVendor.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Cannot load Return To Vendor page.");
            request.getRequestDispatcher("returnToVendor.jsp").forward(request, response);
        }
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
        User acc = (User) session.getAttribute("acc");

        if (acc == null) {
            response.sendRedirect("login");
            return;
        }

        String action = request.getParameter("action");
        String ipAddress = request.getRemoteAddr();
        ReturnToVendorDAO dao = new ReturnToVendorDAO();

        try {
            if ("create".equals(action)) {
                handleCreate(request, response, dao, acc, ipAddress);
                return;
            }

            if ("approve".equals(action)) {
                int rtvID = Integer.parseInt(request.getParameter("rtvID"));
                boolean ok = dao.approveReturn(rtvID, acc.getUserID(), ipAddress);
                response.sendRedirect("return-to-vendor?action=detail&id=" + rtvID + (ok ? "&msg=approved" : "&error=approve_failed"));
                return;
            }

            if ("reject".equals(action)) {
                int rtvID = Integer.parseInt(request.getParameter("rtvID"));
                String rejectNote = request.getParameter("rejectNote");
                boolean ok = dao.rejectReturn(rtvID, acc.getUserID(), rejectNote, ipAddress);
                response.sendRedirect("return-to-vendor?action=detail&id=" + rtvID + (ok ? "&msg=rejected" : "&error=reject_failed"));
                return;
            }

            if ("complete".equals(action)) {
                int rtvID = Integer.parseInt(request.getParameter("rtvID"));
                boolean ok = dao.completeReturnToVendor(rtvID, acc.getUserID(), ipAddress);
                response.sendRedirect("return-to-vendor?action=detail&id=" + rtvID + (ok ? "&msg=completed" : "&error=complete_failed"));
                return;
            }

            response.sendRedirect("return-to-vendor");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("return-to-vendor?error=system_error");
        }
    }

    private void handleCreate(HttpServletRequest request, HttpServletResponse response,
            ReturnToVendorDAO dao, User acc, String ipAddress)
            throws ServletException, IOException {

        try {
            int supplierID = Integer.parseInt(request.getParameter("supplierID"));
            String reason = request.getParameter("reason");
            String note = request.getParameter("note");
            String settlementType = request.getParameter("settlementType");

            String[] stockInDetailIDs = request.getParameterValues("stockInDetailID");
            String[] productIDs = request.getParameterValues("productID");
            String[] quantities = request.getParameterValues("quantity");
            String[] reasonDetails = request.getParameterValues("reasonDetail");
            String[] itemConditions = request.getParameterValues("itemCondition");

            if (stockInDetailIDs == null || stockInDetailIDs.length == 0) {
                request.setAttribute("error", "Please add at least one item.");
                request.getRequestDispatcher("returnToVendorCreate.jsp").forward(request, response);
                return;
            }

            ReturnToVendor rtv = new ReturnToVendor();
            rtv.setReturnCode(generateReturnCode());
            rtv.setSupplierID(supplierID);
            rtv.setCreatedBy(acc.getUserID());
            rtv.setStatus("Pending");
            rtv.setReason(reason);
            rtv.setNote(note);
            rtv.setSettlementType(settlementType);

            List<ReturnToVendorDetail> details = new ArrayList<>();
            Set<Integer> usedStockInDetailIDs  = new HashSet<>();
            StockInDAO stockInDAO = new StockInDAO();

            for (int i = 0; i < stockInDetailIDs.length; i++) {
                if (stockInDetailIDs[i] == null || stockInDetailIDs[i].trim().isEmpty()) {
                    continue;
                }
                if (productIDs[i] == null || productIDs[i].trim().isEmpty()) {
                    continue;
                }
                if (quantities[i] == null || quantities[i].trim().isEmpty()) {
                    continue;
                }

                int stockInDetailID = Integer.parseInt(stockInDetailIDs[i]);
                int productID = Integer.parseInt(productIDs[i]);
                int quantity = Integer.parseInt(quantities[i]);

                if (quantity <= 0) {
                    continue;
                }
                if (usedStockInDetailIDs.contains(stockInDetailID)) {
                    continue;
                }

                StockInDetail sid = stockInDAO.getStockInDetailByDetailId(stockInDetailID);
                if (sid == null) {
                    continue;
                }

                ReturnToVendorDetail detail = new ReturnToVendorDetail();
                detail.setStockInDetailID(stockInDetailID);
                detail.setStockInID(sid.getStockInId());
                detail.setProductID(productID);
                detail.setQuantity(quantity);
                detail.setUnitCost(sid.getUnitCost());
                detail.setLineTotal(quantity * sid.getUnitCost());
                detail.setReasonDetail(reasonDetails != null && reasonDetails.length > i ? reasonDetails[i] : null);
                detail.setItemCondition(itemConditions != null && itemConditions.length > i ? itemConditions[i] : null);

                details.add(detail);
                usedStockInDetailIDs .add(stockInDetailID);
            }

            if (details.isEmpty()) {
                request.setAttribute("error", "Invalid return details.");
                request.getRequestDispatcher("returnToVendorCreate.jsp").forward(request, response);
                return;
            }

            int rtvID = dao.createReturnWithDetails(rtv, details, ipAddress);

            if (rtvID > 0) {
                response.sendRedirect("return-to-vendor?action=detail&id=" + rtvID + "&msg=created");
            } else {
                request.setAttribute("error", "Create return to vendor failed.");
                request.getRequestDispatcher("returnToVendorCreate.jsp").forward(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Invalid input data.");
            request.getRequestDispatcher("returnToVendorCreate.jsp").forward(request, response);
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
