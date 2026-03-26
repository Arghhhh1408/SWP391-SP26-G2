package utils;

import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import model.ReturnRequest;
import model.Product;
import model.OrderHistory;
import dao.OrderHistoryDAO;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

/**
 * Pure Utility for Excel operations. 
 * Contains NO database or business logic.
 */
public class ExcelUtils {

    /**
     * Exports products to Excel.
     * @param products List of products to export
     * @param categoryMap Map of categoryId to categoryName for display
     * @param out OutputStream to write to
     */
    public static void exportProducts(List<Product> products, Map<Integer, String> categoryMap, OutputStream out) throws Exception {
        try (Workbook workbook = new XSSFWorkbook()) {
            Sheet sheet = workbook.createSheet("Products");

            // Create Header Row
            Row headerRow = sheet.createRow(0);
            String[] columns = {"Name", "SKU", "Cost", "Price", "Quantity", "Unit", "Category", "Status", "Description", "Image URL"};
            
            CellStyle headStyle = workbook.createCellStyle();
            Font headFont = workbook.createFont();
            headFont.setBold(true);
            headStyle.setFont(headFont);

            for (int i = 0; i < columns.length; i++) {
                Cell cell = headerRow.createCell(i);
                cell.setCellValue(columns[i]);
                cell.setCellStyle(headStyle);
            }

            int rowNum = 1;
            for (Product p : products) {
                Row row = sheet.createRow(rowNum++);
                row.createCell(0).setCellValue(p.getName());
                row.createCell(1).setCellValue(p.getSku());
                row.createCell(2).setCellValue(p.getCost());
                row.createCell(3).setCellValue(p.getPrice());
                row.createCell(4).setCellValue(p.getQuantity());
                row.createCell(5).setCellValue(p.getUnit());
                
                String catName = (categoryMap != null) ? categoryMap.getOrDefault(p.getCategoryId(), String.valueOf(p.getCategoryId())) : String.valueOf(p.getCategoryId());
                row.createCell(6).setCellValue(catName);
                
                row.createCell(7).setCellValue(p.getStatus());
                row.createCell(8).setCellValue(p.getDescription());
                row.createCell(9).setCellValue(p.getImageURL());
            }

            for (int i = 0; i < columns.length; i++) {
                sheet.autoSizeColumn(i);
            }

            workbook.write(out);
        }
    }

    /**
     * Parses Excel into raw ImportedProduct objects.
     */
    public static List<ImportedProduct> parseProducts(InputStream in) throws Exception {
        List<ImportedProduct> list = new ArrayList<>();
        try (Workbook workbook = new XSSFWorkbook(in)) {
            Sheet sheet = workbook.getSheetAt(0);
            Iterator<Row> rowIterator = sheet.iterator();

            if (rowIterator.hasNext()) rowIterator.next(); // Skip header

            int currentExcelRow = 1; // Row 0 is header
            while (rowIterator.hasNext()) {
                Row row = rowIterator.next();
                currentExcelRow++;
                
                String name = getCellValueAsString(row.getCell(0));
                String sku = getCellValueAsString(row.getCell(1));
                
                // Skip completely empty rows or rows missing both name and sku
                if (name.isEmpty() && sku.isEmpty()) {
                    continue;
                }
                
                ImportedProduct ip = new ImportedProduct();
                ip.rowNum = currentExcelRow;
                ip.name = name;
                ip.sku = sku;
                ip.cost = getCellValueAsDouble(row.getCell(2));
                ip.price = getCellValueAsDouble(row.getCell(3));
                ip.quantity = (int) getCellValueAsDouble(row.getCell(4));
                ip.unit = getCellValueAsString(row.getCell(5));
                ip.categoryName = getCellValueAsString(row.getCell(6));
                ip.status = getCellValueAsString(row.getCell(7));
                ip.description = getCellValueAsString(row.getCell(8));
                ip.imageUrl = getCellValueAsString(row.getCell(9));
                list.add(ip);
            }
        }
        return list;
    }

    /**
     * Exports order history to Excel.
     */
    public static void exportOrderHistory(List<OrderHistory> orders, OutputStream out) throws Exception {
        try (Workbook workbook = new XSSFWorkbook()) {
            Sheet sheet = workbook.createSheet("Báo cáo xuất kho");
            setupHeader(workbook, sheet, new String[]{"Mã HĐ", "Ngày tạo", "Khách hàng", "Số điện thoại", "Người tạo", "Tổng tiền", "Ghi chú"});

            int rowIdx = 1;
            for (OrderHistory o : orders) {
                Row row = sheet.createRow(rowIdx++);
                row.createCell(0).setCellValue(o.getStockOutId());
                row.createCell(1).setCellValue(o.getDate() != null ? o.getDate().toString() : "");
                row.createCell(2).setCellValue(o.getCustomerName() != null ? o.getCustomerName() : "Khách lẻ");
                row.createCell(3).setCellValue(o.getCustomerPhone() != null ? o.getCustomerPhone() : "");
                row.createCell(4).setCellValue(o.getCreatedByName() != null ? o.getCreatedByName() : "");
                row.createCell(5).setCellValue(o.getTotalAmount());
                row.createCell(6).setCellValue(o.getNote() != null ? o.getNote() : "");
            }
            autoSize(sheet, 7);
            workbook.write(out);
        }
    }

    // 1. Báo cáo Tồn kho
    public static void exportInventoryReport(List<Product> products, Map<Integer, String> categoryMap, OutputStream out) throws Exception {
        try (Workbook workbook = new XSSFWorkbook()) {
            Sheet sheet = workbook.createSheet("Báo cáo Tồn kho");
            setupHeader(workbook, sheet, new String[]{"SKU", "Tên sản phẩm", "Danh mục", "Đơn vị", "Tồn kho", "Giá vốn", "Giá bán", "Giá trị tồn", "Trạng thái"});

            CellStyle lowStockStyle = workbook.createCellStyle();
            Font redFont = workbook.createFont();
            redFont.setColor(IndexedColors.RED.getIndex());
            lowStockStyle.setFont(redFont);

            int rowIdx = 1;
            for (Product p : products) {
                Row row = sheet.createRow(rowIdx++);
                row.createCell(0).setCellValue(p.getSku());
                row.createCell(1).setCellValue(p.getName());
                row.createCell(2).setCellValue(categoryMap.getOrDefault(p.getCategoryId(), "---"));
                row.createCell(3).setCellValue(p.getUnit());
                row.createCell(4).setCellValue(p.getQuantity());
                row.createCell(5).setCellValue(p.getCost());
                row.createCell(6).setCellValue(p.getPrice());
                row.createCell(7).setCellValue(p.getQuantity() * p.getCost());

                boolean isLow = p.getQuantity() < p.getLowStockThreshold();
                Cell statusCell = row.createCell(8);
                statusCell.setCellValue(isLow ? "Sắp hết hàng" : "Bình thường");
                if (isLow) statusCell.setCellStyle(lowStockStyle);
            }
            autoSize(sheet, 9);
            workbook.write(out);
        }
    }

    // 2. Báo cáo Doanh thu & Lợi nhuận
    public static void exportSalesReport(List<dao.OrderHistoryDAO.DailyReport> reports, OutputStream out) throws Exception {
        try (Workbook workbook = new XSSFWorkbook()) {
            Sheet sheet = workbook.createSheet("Báo cáo Doanh Thu");
            setupHeader(workbook, sheet, new String[]{"Ngày", "Số đơn hàng", "Doanh thu", "Giá vốn", "Lợi nhuận"});

            int rowIdx = 1;
            for (dao.OrderHistoryDAO.DailyReport r : reports) {
                Row row = sheet.createRow(rowIdx++);
                row.createCell(0).setCellValue(r.getDate().toString());
                row.createCell(1).setCellValue(r.getOrderCount());
                row.createCell(2).setCellValue(r.getRevenue());
                row.createCell(3).setCellValue(r.getCost());
                row.createCell(4).setCellValue(r.getProfit());
            }
            autoSize(sheet, 5);
            workbook.write(out);
        }
    }

    // 3a. Chi tiết Nhập kho
    public static void exportStockInDetails(List<dao.StockInDAO.StockInDetailReport> details, OutputStream out) throws Exception {
        try (Workbook workbook = new XSSFWorkbook()) {
            Sheet sheet = workbook.createSheet("Chi tiết Nhập kho");
            setupHeader(workbook, sheet, new String[]{"Ngày", "Mã phiếu", "Nhà cung cấp", "Sản phẩm", "Số lượng", "Đơn giá nhập", "Thành tiền"});

            int rowIdx = 1;
            for (dao.StockInDAO.StockInDetailReport d : details) {
                Row row = sheet.createRow(rowIdx++);
                row.createCell(0).setCellValue(d.getDate().toString());
                row.createCell(1).setCellValue(d.getStockInId());
                row.createCell(2).setCellValue(d.getSupplierName());
                row.createCell(3).setCellValue(d.getProductName());
                row.createCell(4).setCellValue(d.getQuantity());
                row.createCell(5).setCellValue(d.getUnitCost());
                row.createCell(6).setCellValue(d.getTotalCost());
            }
            autoSize(sheet, 7);
            workbook.write(out);
        }
    }

    // 3b. Chi tiết Xuất kho
    public static void exportStockOutDetails(List<dao.OrderHistoryDAO.StockOrderDetail> details, OutputStream out) throws Exception {
        try (Workbook workbook = new XSSFWorkbook()) {
            Sheet sheet = workbook.createSheet("Chi tiết Xuất kho");
            setupHeader(workbook, sheet, new String[]{"Ngày", "Mã HĐ", "Sản phẩm", "Số lượng", "Giá bán", "Doanh thu"});

            int rowIdx = 1;
            for (dao.OrderHistoryDAO.StockOrderDetail d : details) {
                Row row = sheet.createRow(rowIdx++);
                row.createCell(0).setCellValue(d.getDate().toString());
                row.createCell(1).setCellValue(d.getOrderId());
                row.createCell(2).setCellValue(d.getProductName());
                row.createCell(3).setCellValue(d.getQuantity());
                row.createCell(4).setCellValue(d.getPrice());
                row.createCell(5).setCellValue(d.getTotal());
            }
            autoSize(sheet, 6);
            workbook.write(out);
        }
    }

    // 4. Báo cáo Hiệu suất (Top Sản phẩm)
    public static void exportPerformanceReport(List<dao.ProductDAO.ProductPerformance> performance, OutputStream out) throws Exception {
        try (Workbook workbook = new XSSFWorkbook()) {
            Sheet sheet = workbook.createSheet("Top Sản phẩm");
            setupHeader(workbook, sheet, new String[]{"Hạng", "SKU", "Tên sản phẩm", "Số lượng bán", "Doanh thu"});

            int rowIdx = 1;
            int rank = 1;
            for (dao.ProductDAO.ProductPerformance p : performance) {
                Row row = sheet.createRow(rowIdx++);
                row.createCell(0).setCellValue(rank++);
                row.createCell(1).setCellValue(p.getSku());
                row.createCell(2).setCellValue(p.getName());
                row.createCell(3).setCellValue(p.getQuantitySold());
                row.createCell(4).setCellValue(p.getRevenueGenerated());
            }
            autoSize(sheet, 5);
            workbook.write(out);
        }
    }

    /**
     * Staff dashboard report (multi-sheet workbook).
     * Each dataset is exported as a separate sheet.
     */
    public static void exportStaffMultiSheetReport(
            List<Product> products,
            Map<Integer, String> categoryMap,
            List<OrderHistoryDAO.DailyReport> dailySales,
            List<OrderHistoryDAO.StockOrderDetail> soldDetails,
            List<ReturnRequest> returns,
            OutputStream out
    ) throws Exception {
        try (Workbook workbook = new XSSFWorkbook()) {
            // Sheet 1: Inventory (current products)
            Sheet sInv = workbook.createSheet("Tồn kho hiện có");
            setupHeader(workbook, sInv, new String[]{"SKU", "Tên sản phẩm", "Danh mục", "Đơn vị", "Tồn kho", "Giá vốn", "Giá bán", "Trạng thái"});
            int r1 = 1;
            if (products != null) {
                for (Product p : products) {
                    Row row = sInv.createRow(r1++);
                    row.createCell(0).setCellValue(nz(p.getSku()));
                    row.createCell(1).setCellValue(nz(p.getName()));
                    row.createCell(2).setCellValue(categoryMap == null ? "" : categoryMap.getOrDefault(p.getCategoryId(), "---"));
                    row.createCell(3).setCellValue(nz(p.getUnit()));
                    row.createCell(4).setCellValue(p.getQuantity());
                    row.createCell(5).setCellValue(p.getCost());
                    row.createCell(6).setCellValue(p.getPrice());
                    row.createCell(7).setCellValue(nz(p.getStatus()));
                }
            }
            autoSize(sInv, 8);

            // Sheet 2: Revenue from orders (daily)
            Sheet sRev = workbook.createSheet("Doanh thu từ đơn");
            setupHeader(workbook, sRev, new String[]{"Ngày", "Số đơn", "Doanh thu", "Giá vốn", "Lợi nhuận"});
            int r2 = 1;
            if (dailySales != null) {
                for (OrderHistoryDAO.DailyReport d : dailySales) {
                    Row row = sRev.createRow(r2++);
                    row.createCell(0).setCellValue(d.getDate() == null ? "" : d.getDate().toString());
                    row.createCell(1).setCellValue(d.getOrderCount());
                    row.createCell(2).setCellValue(d.getRevenue());
                    row.createCell(3).setCellValue(d.getCost());
                    row.createCell(4).setCellValue(d.getProfit());
                }
            }
            autoSize(sRev, 5);

            // Sheet 3: Sold products / orders
            Sheet sSold = workbook.createSheet("Sản phẩm đã bán");
            setupHeader(workbook, sSold, new String[]{"Ngày", "Mã đơn", "Sản phẩm", "Số lượng", "Đơn giá", "Doanh thu"});
            int r3 = 1;
            if (soldDetails != null) {
                for (OrderHistoryDAO.StockOrderDetail d : soldDetails) {
                    Row row = sSold.createRow(r3++);
                    row.createCell(0).setCellValue(d.getDate() == null ? "" : d.getDate().toString());
                    row.createCell(1).setCellValue(d.getOrderId());
                    row.createCell(2).setCellValue(nz(d.getProductName()));
                    row.createCell(3).setCellValue(d.getQuantity());
                    row.createCell(4).setCellValue(d.getPrice());
                    row.createCell(5).setCellValue(d.getTotal());
                }
            }
            autoSize(sSold, 6);

            // Sheet 4: Returned products
            Sheet sRet = workbook.createSheet("Sản phẩm trả hàng");
            setupHeader(workbook, sRet, new String[]{"Mã yêu cầu", "SKU", "Sản phẩm", "Khách hàng", "SĐT", "Giá sản phẩm", "Số tiền hoàn", "Lý do", "Trạng thái", "Cập nhật"});
            int r4 = 1;
            if (returns != null) {
                for (ReturnRequest rr : returns) {
                    Row row = sRet.createRow(r4++);
                    row.createCell(0).setCellValue(nz(rr.getReturnCode()));
                    row.createCell(1).setCellValue(nz(rr.getSku()));
                    row.createCell(2).setCellValue(nz(rr.getProductName()));
                    row.createCell(3).setCellValue(nz(rr.getCustomerName()));
                    row.createCell(4).setCellValue(nz(rr.getCustomerPhone()));
                    Double pp = rr.getProductPrice();
                    Double ra = rr.getRefundAmount();
                    double ppv = pp == null ? 0d : pp;
                    double rav = ra == null ? 0d : ra;
                    row.createCell(5).setCellValue(ppv);
                    row.createCell(6).setCellValue(rav);
                    row.createCell(7).setCellValue(nz(rr.getReason()));
                    row.createCell(8).setCellValue(rr.getStatus() == null ? "" : rr.getStatus().name());
                    row.createCell(9).setCellValue(rr.getUpdatedAt() == null ? "" : rr.getUpdatedAt().toString());
                }
            }
            autoSize(sRet, 10);

            workbook.write(out);
        }
    }

    private static String nz(String s) {
        return s == null ? "" : s;
    }

    private static void setupHeader(Workbook wb, Sheet sheet, String[] columns) {
        Row headerRow = sheet.createRow(0);
        CellStyle style = wb.createCellStyle();
        Font font = wb.createFont();
        font.setBold(true);
        font.setColor(IndexedColors.WHITE.getIndex());
        style.setFont(font);
        style.setFillForegroundColor(IndexedColors.BLUE_GREY.getIndex());
        style.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        style.setAlignment(HorizontalAlignment.CENTER);

        for (int i = 0; i < columns.length; i++) {
            Cell cell = headerRow.createCell(i);
            cell.setCellValue(columns[i]);
            cell.setCellStyle(style);
        }
    }

    private static void autoSize(Sheet sheet, int colCount) {
        for (int i = 0; i < colCount; i++) {
            sheet.autoSizeColumn(i);
        }
    }

    private static String getCellValueAsString(Cell cell) {
        if (cell == null) return "";
        DataFormatter formatter = new DataFormatter();
        return formatter.formatCellValue(cell).trim();
    }

    private static double getCellValueAsDouble(Cell cell) {
        if (cell == null) return 0;
        try {
            if (cell.getCellType() == CellType.NUMERIC) {
                return cell.getNumericCellValue();
            } else if (cell.getCellType() == CellType.STRING) {
                String val = cell.getStringCellValue().trim();
                return val.isEmpty() ? 0 : Double.parseDouble(val);
            }
        } catch (Exception e) {}
        return 0;
    }

    /**
     * DTO for imported data before validation/DB mapping.
     */
    public static class ImportedProduct {
        public String name, sku, unit, categoryName, status, description, imageUrl;
        public double cost, price;
        public int quantity;
        public int rowNum;
    }
}
