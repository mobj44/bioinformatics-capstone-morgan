# genome assembly name, busco, N50
from pathlib import Path
import json
import csv

BUSCO_FIELDS = [
    "Complete percentage",
    "Complete BUSCOs",
    "Single copy percentage",
    "Single copy BUSCOs",
    "Multi copy percentage",
    "Multi copy BUSCOs",
    "Fragmented percentage",
    "Fragmented BUSCOs",
    "Missing percentage",
    "Missing BUSCOs",
    "n_markers",
    "domain",
    "Number of scaffolds",
    "Number of contigs",
    "Total length",
    "Percent gaps",
    "Scaffold N50",
    "Contigs N50",
    "translation_table",
]


def get_acc_nums(path, busco_results) -> dict[str, str]:
    with open(path, "r") as file:
        sample_dict = {}
        acc_nums = [line.strip() for line in file if line.strip()]

        for acc in acc_nums:
            busco_match = next((p for p in busco_results if p.name.startswith(acc + "_")), None)
            if busco_match:
                sample_dict[acc] = busco_match

        return sample_dict
    
def make_busco_csv(path_for_csv, busco_dict):
    with open(path_for_csv, "w") as file: 
        fieldnames = ["Accession Number"] + BUSCO_FIELDS
        writer = csv.DictWriter(file, fieldnames=fieldnames)
        writer.writeheader()

        for acc, folder_path in busco_dict.items():
            json_matches = list(folder_path.rglob("short_summary*.json"))
            if not json_matches:
                print(f"WARN: missing short_summary*.json in {folder_path.name}")
                continue

            json_file = json_matches[0]

            with open(json_file, "r", encoding="utf-8") as f:
                busco_data = json.load(f)

            results = busco_data.get("results", {})

            # use accession number only
            row = {"Accession Number": acc}
            for field in BUSCO_FIELDS:
                row[field] = results.get(field, "")

            writer.writerow(row)


def main():
    # project root path
    project_root = Path(".").absolute()

    # path to quality reports
    busco_reports_path = project_root / "data" / "assembly_evaluation" / "busco"
    
    # path for analysis csv's 
    analysis_path = project_root / "analysis" / "assembly_evaluation"
    analysis_path.mkdir(parents=True, exist_ok=True)

    # path to busco results csv
    busco_out_csv = analysis_path / "busco_summary.csv"

    # accession number path, for easy naming in csv's 
    assembly_accessions_path = project_root / "data" / "accession_files" / "assembly_accessions.txt"    

    # list of busco result folders from data
    busco_folder_paths = [busco_report for busco_report in busco_reports_path.iterdir() if busco_report.is_dir()]

    busco_dict = get_acc_nums(assembly_accessions_path, busco_folder_paths)
    make_busco_csv(busco_out_csv, busco_dict)
    




if __name__ == "__main__":
    main()