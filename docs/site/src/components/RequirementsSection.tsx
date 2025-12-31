import { Container, MonitorUp, Puzzle, CheckCircle } from "lucide-react";

interface Requirement {
  icon: React.ElementType;
  name: string;
  description: string;
  options?: string[];
}

const requirements: Requirement[] = [
  {
    icon: Container,
    name: "Container Runtime",
    description: "For running the isolated Dev Container environment",
    options: ["Docker Desktop", "OrbStack (macOS)"],
  },
  {
    icon: MonitorUp,
    name: "IDE",
    description: "Any editor with Dev Containers support",
    options: ["VS Code", "Cursor", "Windsurf", "Antigravity"],
  },
  {
    icon: Puzzle,
    name: "Dev Containers Extension",
    description: "Required for container integration",
    options: ["Install from VS Code Marketplace"],
  },
];

const SectionHeader = ({ title, subtitle }: { title: string; subtitle?: string }) => (
  <div className="text-center mb-12">
    <h2 className="text-2xl sm:text-3xl md:text-4xl font-bold text-foreground mb-4">
      {title}
    </h2>
    {subtitle && (
      <p className="text-muted-foreground text-base sm:text-lg max-w-2xl mx-auto">
        {subtitle}
      </p>
    )}
  </div>
);

const RequirementsSection = () => {
  return (
    <section id="requirements" className="py-20 lg:py-28 px-4 sm:px-6 bg-card/30">
      <div className="absolute top-0 left-0 right-0 h-px bg-gradient-to-r from-transparent via-border to-transparent" />
      <div className="max-w-4xl mx-auto">
        <SectionHeader
          title="Prerequisites"
          subtitle="Everything you need to get started"
        />

        <div className="glass rounded-2xl p-6 sm:p-8">
          <div className="flex items-center gap-2 mb-6">
            <CheckCircle className="h-5 w-5 text-green-500" />
            <span className="text-foreground font-semibold">That's all you need</span>
          </div>

          <div className="space-y-4">
            {requirements.map((req) => {
              const Icon = req.icon;
              return (
                <div
                  key={req.name}
                  className="flex items-start gap-4 p-4 bg-background/50 rounded-xl"
                >
                  <div className="w-10 h-10 bg-primary/10 rounded-lg flex items-center justify-center flex-shrink-0">
                    <Icon className="h-5 w-5 text-primary" />
                  </div>
                  <div className="flex-1">
                    <h4 className="text-foreground font-semibold text-sm sm:text-base mb-1">
                      {req.name}
                    </h4>
                    <p className="text-muted-foreground text-xs sm:text-sm mb-2">
                      {req.description}
                    </p>
                    {req.options && (
                      <div className="flex flex-wrap gap-2">
                        {req.options.map((option) => (
                          <span
                            key={option}
                            className="text-xs px-2 py-1 bg-primary/10 text-primary rounded-md"
                          >
                            {option}
                          </span>
                        ))}
                      </div>
                    )}
                  </div>
                </div>
              );
            })}
          </div>

          <p className="text-muted-foreground text-xs sm:text-sm mt-6 flex items-start gap-2">
            <span className="text-primary">Note:</span>
            <span>
              Claude CodePro runs inside a Dev Container for complete isolation,
              consistent tooling, and cross-platform compatibility.
            </span>
          </p>
        </div>
      </div>
    </section>
  );
};

export default RequirementsSection;
