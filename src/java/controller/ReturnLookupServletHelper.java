package controller;

import dao.ReturnLookupDAO;
import jakarta.servlet.http.HttpServletRequest;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import model.ReturnLookupResult;

/**
 * Tra cứu trả hàng: ô tìm kiếm + sắp xếp + phân trang (dùng chung Sales / Manager / Staff).
 */
final class ReturnLookupServletHelper {

    private ReturnLookupServletHelper() {
    }

    static void applyReturnLookup(HttpServletRequest request) {
        String keyword = blankToNull(trim(request.getParameter("q")));
        if (keyword == null) {
            String rq = trim(request.getParameter("rq"));
            if (rq != null && !rq.isEmpty() && rq.chars().allMatch(Character::isDigit)) {
                keyword = rq;
            }
        }

        String sort = trim(request.getParameter("rlSort"));
        if (sort == null || sort.isEmpty()) {
            sort = "purchase_date";
        }

        int page = clampPage(tryParseInt(trim(request.getParameter("rlPage"))), 1);
        Integer ps = tryParseInt(trim(request.getParameter("rlPageSize")));
        int pageSize = ps == null ? 10 : Math.min(50, Math.max(1, ps));

        boolean runSearch = keyword != null;

        request.setAttribute("rlq", keyword == null ? "" : keyword);
        request.setAttribute("returnLookupSort", sort);
        request.setAttribute("returnLookupPage", page);
        request.setAttribute("returnLookupPageSize", pageSize);

        if (!runSearch) {
            request.setAttribute("returnLookupResults", Collections.emptyList());
            request.setAttribute("returnLookupTotal", 0);
            request.setAttribute("returnLookupTotalPages", 1);
            request.setAttribute("returnLookupHasFilter", false);
            return;
        }

        ReturnLookupDAO dao = new ReturnLookupDAO();
        int total = dao.countUnifiedSearch(keyword);
        int totalPages = total <= 0 ? 1 : (int) Math.ceil((double) total / pageSize);
        if (page > totalPages) {
            page = totalPages;
        }
        request.setAttribute("returnLookupPage", page);

        List<ReturnLookupResult> results = new ArrayList<>();
        if (total > 0) {
            results = dao.searchUnified(keyword, sort, page, pageSize);
        }

        request.setAttribute("returnLookupResults", results);
        request.setAttribute("returnLookupTotal", total);
        request.setAttribute("returnLookupTotalPages", totalPages);
        request.setAttribute("returnLookupHasFilter", true);
    }

    private static String trim(String s) {
        return s == null ? null : s.trim();
    }

    private static String blankToNull(String s) {
        if (s == null || s.isEmpty()) {
            return null;
        }
        return s;
    }

    private static Integer tryParseInt(String s) {
        if (s == null || s.isEmpty()) {
            return null;
        }
        try {
            return Integer.parseInt(s);
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private static int clampPage(Integer p, int def) {
        if (p == null || p < 1) {
            return def;
        }
        return p;
    }
}
