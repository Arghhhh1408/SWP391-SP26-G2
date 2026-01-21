/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dao.UserDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 *
 * @author minhtuan
 */
@WebServlet(name = "DeleteUserController", urlPatterns = { "/deleteUser" })
public class DeleteUserController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        UserDAO dao = new UserDAO();
        dao.deleteUser(id);
        HttpSession session = request.getSession();
        try {
            dao.deleteUser(id);
            request.setAttribute("message", "Xóa tài khoản thành công");
            request.setAttribute("status", "success");
        } catch (Exception e) {
            request.setAttribute("message", "Xóa tài khoản thất bại");
            request.setAttribute("status", "failure");
            e.printStackTrace();
        }
        request.getRequestDispatcher("userList").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
    }

}
