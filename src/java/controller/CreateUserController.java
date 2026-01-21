/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dao.RoleDAO;
import dao.UserDAO;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.util.List;
import model.Role;
import model.User;

/**
 *
 * @author minhtuan
 */
@WebServlet(name = "CreateAccountController", urlPatterns = { "/createuser" })
public class CreateUserController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User u = (User) session.getAttribute("acc");
        if (u == null || u.getRoleID() != 0) {
            response.sendRedirect("login");
            return;
        }

        RoleDAO dao = new RoleDAO();
        List<Role> listOfRole = dao.getAllRole();
        request.setAttribute("listOfRole", listOfRole);
        request.getRequestDispatcher("createUser.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String fullName = request.getParameter("fullname");
        String phone = request.getParameter("phone");
        String email = request.getParameter("email");
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        int roleID = Integer.parseInt(request.getParameter("role"));

        // Validate Phone Format
        if (!utils.ValidationUtils.isValidPhone(phone)) {
            request.setAttribute("error",
                    "Invalid phone number format! Must be 10 digits starting with 03, 07, 08, 09.");

            RoleDAO roleDao = new RoleDAO();
            request.setAttribute("listOfRole", roleDao.getAllRole());
            request.getRequestDispatcher("createUser.jsp").forward(request, response);
            return;
        }

        // Validate Email Format
        if (!utils.ValidationUtils.isValidEmail(email)) {
            request.setAttribute("error", "Invalid email format!");
            RoleDAO roleDao = new RoleDAO();
            request.setAttribute("listOfRole", roleDao.getAllRole());
            request.getRequestDispatcher("createUser.jsp").forward(request, response);
            return;
        }

        UserDAO dao = new UserDAO();
        String error = dao.checkDuplicate(username, email, phone);
        if (error != null) {
            request.setAttribute("error", error);
            RoleDAO roleDao = new RoleDAO();
            request.setAttribute("listOfRole", roleDao.getAllRole());
            request.getRequestDispatcher("createUser.jsp").forward(request, response);
            return;
        }

        User newUser = new User(username, password, fullName, roleID, email, phone, true);
        boolean success = dao.addUser(newUser);

        if (success) {
            request.setAttribute("message", "Cấp tài khoản mới thành công");
            request.setAttribute("status", "success");
        } else {
            request.setAttribute("message", "Cấp tài khoản mới thất bại");
            request.setAttribute("status", "failure");
        }
        RoleDAO roleDao = new RoleDAO();
        request.setAttribute("listOfRole", roleDao.getAllRole());
        request.getRequestDispatcher("createUser.jsp").forward(request, response);
    }

}
