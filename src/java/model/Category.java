package model;

public class Category {
    private int id;
    private String name;
    private Integer parentId;
    private java.util.List<Category> children = new java.util.ArrayList<>();

    public Category() {
    }

    public Category(int id, String name, Integer parentId) {
        this.id = id;
        this.name = name;
        this.parentId = parentId;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Integer getParentId() {
        return parentId;
    }

    public void setParentId(Integer parentId) {
        this.parentId = parentId;
    }

    public java.util.List<Category> getChildren() {
        return children;
    }

    public void setChildren(java.util.List<Category> children) {
        this.children = children;
    }

    @Override
    public String toString() {
        return "Category{" + "id=" + id + ", name=" + name + ", parentId=" + parentId + '}';
    }
}
