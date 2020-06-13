import pathlib
import re


def format_entry(phenotype_path):
    directory = phenotype_path.parent
    readme_path = directory.joinpath('README.md')
    assert readme_path.exists()

    with open(readme_path, 'r') as f:
        readme = f.read()

    with open(phenotype_path, 'r') as f:
        phenotype = f.read()

    # Format risk factors themselves
    readme = re.sub('<!---\n|\n-->', '', readme)
    readme = readme.format(phenotype)

    # Format table of contents
    phenotype_name = re.search('(?<=## ).+(?=\s)', readme).group()
    phenotype_link = re.sub('\s', '-', phenotype_name.lower())
    table_of_contents_entry = f'[{phenotype_name}](#{phenotype_link}-)<br/>\n'
    return table_of_contents_entry, readme


# Find all defined phenotypes (risk factors and measurements)
phenotype_paths = sorted(pathlib.Path('covid_phenotypes/')
                         .glob('**/phenotype.sql'))
measurement_paths = [phenotype for phenotype in phenotype_paths
                     if phenotype.parent.parent.name == 'measurements']
risk_factor_paths = [phenotype for phenotype in phenotype_paths
                     if phenotype not in measurement_paths]

risk_factor_table_of_contents = ''
risk_factor_definitions = ''
for phenotype_path in risk_factor_paths:
    table_of_contents_entry, definition = format_entry(phenotype_path)
    risk_factor_table_of_contents += table_of_contents_entry
    risk_factor_definitions += definition

measurement_table_of_contents = ''
measurement_definitions = ''
for phenotype_path in measurement_paths:
    table_of_contents_entry, definition = format_entry(phenotype_path)
    measurement_table_of_contents += table_of_contents_entry
    measurement_definitions += definition


with open('doc/covid-19-template.md', 'r') as f:
    wiki_template = f.read()

formatted_wiki = wiki_template.format(
    risk_factor_contents=risk_factor_table_of_contents,
    measurement_contents=measurement_table_of_contents,

    risk_factors=risk_factor_definitions,
    measurements=measurement_definitions,
)

with open('doc/completed_wiki.md', 'w') as f:
    f.write(formatted_wiki)
