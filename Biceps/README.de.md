# Biceps

Bicep ist eine domänenspezifische Sprache (DSL), die deklarative Syntax zum Bereitstellen von Azure-Ressourcen verwendet.
Wir verwenden es, um die erforderliche Infrastruktur (z.Bsp. TF State Datei) für Terraform zu generieren.
Bicep stellt Dienste nur dann bereit, wenn sie noch nicht vorhanden sind.

## Infrastruktur einrichten
- Terraform-Speicher (`provider.tf` Backend-Konfiguration), Henne-Ei-Problem
- Azure Keyvault für Azure-Anmeldeinformationen