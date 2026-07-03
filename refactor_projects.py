import os
import shutil

ROOT_DIR = r"e:\AWS Hands-on Projects"
PROJ_12_DIR = os.path.join(ROOT_DIR, "project-12-event-driven-pipeline")
PROJ_PREFIX = "project-"

docs_files = [
    "project-overview.md",
    "architecture.md",
    "deployment-guide.md",
    "security-protocols.md",
    "testing-procedures.md",
    "troubleshooting.md",
    "cleanup-guide.md"
]

def main():
    # Read License and gitignore from Proj 12
    with open(os.path.join(PROJ_12_DIR, "LICENSE"), "r") as f:
        license_content = f.read()
    
    with open(os.path.join(PROJ_12_DIR, ".gitignore"), "r") as f:
        gitignore_content = f.read()

    projects = []
    for d in os.listdir(ROOT_DIR):
        if d.startswith(PROJ_PREFIX) and os.path.isdir(os.path.join(ROOT_DIR, d)):
            try:
                num = int(d.split('-')[1])
                if 1 <= num <= 11:
                    projects.append(d)
            except ValueError:
                pass
    
    print(f"Found {len(projects)} projects to scaffold: {projects}")

    for p in projects:
        p_dir = os.path.join(ROOT_DIR, p)
        print(f"\nProcessing {p}...")

        # 1. Create License and gitignore
        with open(os.path.join(p_dir, "LICENSE"), "w") as f:
            f.write(license_content)
        with open(os.path.join(p_dir, ".gitignore"), "w") as f:
            f.write(gitignore_content)
        
        # 2. Reorganize Scripts
        old_scripts = os.path.join(p_dir, "scripts")
        old_bash = os.path.join(p_dir, "bash-scripts")
        
        ps_dir = os.path.join(p_dir, "scripts", "powershell")
        bash_dir = os.path.join(p_dir, "scripts", "bash")
        
        os.makedirs(ps_dir, exist_ok=True)
        os.makedirs(bash_dir, exist_ok=True)

        # Move files from old scripts to powershell
        if os.path.exists(old_scripts):
            for f in os.listdir(old_scripts):
                src = os.path.join(old_scripts, f)
                if os.path.isfile(src) and src not in [ps_dir, bash_dir]:
                    shutil.move(src, os.path.join(ps_dir, f))
        
        # Move files from old bash-scripts to bash
        if os.path.exists(old_bash):
            for f in os.listdir(old_bash):
                src = os.path.join(old_bash, f)
                if os.path.isfile(src):
                    shutil.move(src, os.path.join(bash_dir, f))
            # Delete old bash-scripts dir if empty
            if not os.listdir(old_bash):
                os.rmdir(old_bash)

        # 3. Create Architecture directory
        os.makedirs(os.path.join(p_dir, "architecture"), exist_ok=True)

        # 4. Docs Directory Placeholders
        docs_dir = os.path.join(p_dir, "docs")
        os.makedirs(docs_dir, exist_ok=True)
        
        for doc in docs_files:
            doc_path = os.path.join(docs_dir, doc)
            if not os.path.exists(doc_path):
                with open(doc_path, "w") as f:
                    # Create a basic placeholder
                    title = doc.replace('.md', '').replace('-', ' ').title()
                    f.write(f"# {title}\n\n*Placeholder content to be generated.*")
        
        print(f"Successfully scaffolded {p}")

if __name__ == "__main__":
    main()
