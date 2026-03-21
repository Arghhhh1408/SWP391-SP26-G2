package utils;

import dao.CategoryDAO;
import dao.ProductDAO;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import model.Product;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.CellType;
import org.apache.poi.ss.usermodel.DataFormatter;
import org.apache.poi.ss.usermodel.Font;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

public class ExcelUtils {

    public static void exportProducts(List<Product> products, OutputStream out) throws Exception {
        Workbook workbook = new XSSFWorkbook();
        Sheet sheet = workbook.createSheet("Products");

        // Create Header Row
        Row headerRow = sheet.createRow(0);
        String[] columns = {"Name", "SKU", "Cost", "Price", "Quantity", "Unit", "Category", "Status", "Description", "Image URL"};
        for (int i = 0; i < columns.length; i++) {
            Cell cell = headerRow.createCell(i);
            cell.setCellValue(columns[i]);
            
            // Basic styling for header
            CellStyle style = workbook.createCellStyle();
            Font font = workbook.createFont();
            font.setBold(true);
            style.setFont(font);
            cell.setCellStyle(style);
        }

        CategoryDAO catDao = new CategoryDAO();
        int rowNum = 1;
        for (Product p : products) {
            Row row = sheet.createRow(rowNum++);
            row.createCell(0).setCellValue(p.getName() != null ? p.getName() : "");
            row.createCell(1).setCellValue(p.getSku() != null ? p.getSku() : "");
            row.createCell(2).setCellValue(p.getCost());
            row.createCell(3).setCellValue(p.getPrice());
            row.createCell(4).setCellValue(p.getQuantity());
            row.createCell(5).setCellValue(p.getUnit() != null ? p.getUnit() : "");
            
            String catName = "";
            model.Category cat = catDao.getCategoryById(p.getCategoryId());
            if (cat != null) catName = cat.getName();
            row.createCell(6).setCellValue(catName);
            
            row.createCell(7).setCellValue(p.getStatus() != null ? p.getStatus() : "");
            row.createCell(8).setCellValue(p.getDescription() != null ? p.getDescription() : "");
            row.createCell(9).setCellValue(p.getImageURL() != null ? p.getImageURL() : "");
        }

        // Auto-size columns
        for (int i = 0; i < columns.length; i++) {
            sheet.autoSizeColumn(i);
        }

        workbook.write(out);
        workbook.close();
    }

    public static ImportResult importProducts(InputStream in) throws Exception {
        ImportResult result = new ImportResult();
        Workbook workbook = null;
        try {
            workbook = new XSSFWorkbook(in);
            Sheet sheet = workbook.getSheetAt(0);
            Iterator<Row> rowIterator = sheet.iterator();

            CategoryDAO catDao = new CategoryDAO();
            ProductDAO prodDao = new ProductDAO();

            // Skip header
            if (rowIterator.hasNext()) rowIterator.next();

            int rowNum = 1;
            while (rowIterator.hasNext()) {
                Row row = rowIterator.next();
                rowNum++;
                try {
                    String name = getCellValueAsString(row.getCell(0));
                    String sku = getCellValueAsString(row.getCell(1));
                    
                    if (name == null || name.isEmpty() || sku == null || sku.isEmpty()) {
                        result.addError("Row " + rowNum + ": Name and SKU are required.");
                        continue;
                    }

                    if (prodDao.isProductSkuExists(sku)) {
                        result.addError("Row " + rowNum + ": SKU '" + sku + "' already exists.");
                        continue;
                    }

                    double cost = getCellValueAsDouble(row.getCell(2));
                    double price = getCellValueAsDouble(row.getCell(3));
                    int quantity = (int) getCellValueAsDouble(row.getCell(4));
                    String unit = getCellValueAsString(row.getCell(5));
                    String categoryName = getCellValueAsString(row.getCell(6));
                    String status = getCellValueAsString(row.getCell(7));
                    String description = getCellValueAsString(row.getCell(8));
                    String imageUrl = getCellValueAsString(row.getCell(9));

                    if (cost < 0 || price < 0 || quantity < 0) {
                        result.addError("Row " + rowNum + ": Cost, Price, and Quantity must be non-negative.");
                        continue;
                    }

                    Integer categoryId = catDao.getCategoryIdByName(categoryName);
                    if (categoryId == null) {
                        result.addError("Row " + rowNum + ": Category '" + categoryName + "' not found.");
                        continue;
                    }

                    Product p = new Product();
                    p.setName(name);
                    p.setSku(sku);
                    p.setCost(cost);
                    p.setPrice(price);
                    p.setQuantity(quantity);
                    p.setUnit(unit);
                    p.setCategoryId(categoryId);
                    p.setStatus(status != null && !status.isEmpty() ? status : "Active");
                    p.setDescription(description);
                    p.setImageURL(imageUrl);

                    result.addValidProduct(p);

                } catch (Exception e) {
                    result.addError("Row " + rowNum + ": Error parsing data - " + e.getMessage());
                }
            }
        } finally {
            if (workbook != null) workbook.close();
        }
        return result;
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
        } catch (Exception e) {
            // Log or ignore
        }
        return 0;
    }

    public static class ImportResult {
        private List<Product> validProducts = new ArrayList<>();
        private List<String> errors = new ArrayList<>();

        public void addValidProduct(Product p) { validProducts.add(p); }
        public void addError(String error) { errors.add(error); }
        public List<Product> getValidProducts() { return validProducts; }
        public List<String> getErrors() { return errors; }
    }
}
