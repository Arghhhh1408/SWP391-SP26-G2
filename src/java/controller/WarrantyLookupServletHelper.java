package controller;

import dao.WarrantyLookupDAO;
import jakarta.servlet.http.HttpServletRequest;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import model.WarrantyLookupResult;

/**
 * Tra cứu bảo hành: một ô tìm kiếm + lọc trạng thái + sắp xếp + phân trang.
 */
final class WarrantyLookupServletHelper {

    private WarrantyLookupServletHelper() {
    }

    static void applyLookup(HttpServletRequest request) {
        String keyword = blankToNull(trim(request.getParameter("q")));
        String warrantyFilter = trim(request.getParameter("wf"));
        if (warrantyFilter == null || warrantyFilter.isEmpty()) {
            warrantyFilter = "all";
        }
        String sort = trim(request.getParameter("sort"));
        if (sort == null || sort.isEmpty()) {
            sort = "purchase_date";
        }

        int page = clampPage(tryParseInt(trim(request.getParameter("page"))), 1);
        Integer ps = tryParseInt(trim(request.getParameter("pageSize")));
        int pageSize = ps == null ? 10 : Math.min(50, Math.max(1, ps));

        boolean runSearch = keyword != null || !"all".equalsIgnoreCase(warrantyFilter);

        request.setAttribute("q", keyword == null ? "" : keyword);
        request.setAttribute("wf", warrantyFilter);
        request.setAttribute("sort", sort);

        if (!runSearch) {
            request.setAttribute("warrantyResults", Collections.emptyList());
            request.setAttribute("warrantyTotal", 0);
            request.setAttribute("warrantyPage", 1);
            request.setAttribute("warrantyPageSize", pageSize);
            request.setAttribute("warrantyTotalPages", 1);
            request.setAttribute("warrantyHasFilter", false);
            return;
        }

        WarrantyLookupDAO wlDao = new WarrantyLookupDAO();
        int total = wlDao.countUnifiedSearch(keyword, warrantyFilter);
        int totalPages = total <= 0 ? 1 : (int) Math.ceil((double) total / pageSize);
        if (page > totalPages) {
            page = totalPages;
        }

        List<WarrantyLookupResult> results = new ArrayList<>();
        if (total > 0) {
            results = wlDao.searchUnified(keyword, warrantyFilter, sort, page, pageSize);
        }

        request.setAttribute("warrantyResults", results);
        request.setAttribute("warrantyTotal", total);
        request.setAttribute("warrantyPage", page);
        request.setAttribute("warrantyPageSize", pageSize);
        request.setAttribute("warrantyTotalPages", totalPages);
        request.setAttribute("warrantyHasFilter", true);
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
