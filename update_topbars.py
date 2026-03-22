import os
import glob

# The directory containing the JSP files
web_dir = r"d:\SWP391\SWP391-SP26-G2\web"

# The original string we are looking for
target_string = r"Xin chào, <strong>${sessionScope.acc.fullName}</strong>"

# The replacement HTML structure
replacement_string = r"""<div style="display: inline-flex; align-items: center; gap: 15px;">
    <a href="${pageContext.request.contextPath}/notifications" style="text-decoration: none; font-size: 20px; position: relative;" title="Thông báo">
        🔔<span style="position: absolute; top: -2px; right: -6px; background: red; color: white; border-radius: 50%; padding: 2px 5px; font-size: 10px; display: none;" id="notificationBadge">0</span>
    </a>
    <span style="border-left: 1px solid #ccc; padding-left: 15px;">Xin chào, <strong>${sessionScope.acc.fullName}</strong></span>
</div>"""

def update_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    if target_string in content and "🔔" not in content:
        print(f"Updating: {filepath}")
        new_content = content.replace(target_string, replacement_string)
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)
        return True
    return False

# Find all jsp files
jsp_files = glob.glob(os.path.join(web_dir, '*.jsp'))
updated_count = 0

for filepath in jsp_files:
    if update_file(filepath):
        updated_count += 1

print(f"Updated {updated_count} files successfully.")
