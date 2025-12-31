import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Mail } from "lucide-react";
import { toast } from "sonner";

interface WaitlistProps {
  variant?: "hero" | "footer";
}

const Waitlist = ({ variant = "hero" }: WaitlistProps) => {
  const [email, setEmail] = useState("");
  const [isSubmitting, setIsSubmitting] = useState(false);

const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsSubmitting(true);
    
    try {
      const response = await fetch('https://api.convertkit.com/v3/forms/8717600/subscribe', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          api_key: '8hC9oRPJUYIVhKZz8cSglw',
          email: email,
        }),
      });

      if (response.ok) {
        toast.success("Success! Please check your email to confirm your spot on the waiting list.");
        setEmail("");
      } else {
        toast.error("Something went wrong. Please try again.");
      }
    } catch (error) {
      console.error('Subscription error:', error);
      toast.error("Failed to subscribe. Please try again.");
    } finally {
      setIsSubmitting(false);
    }
  };

  if (variant === "footer") {
    return (
      <div className="w-full max-w-md">
        <h3 className="text-lg font-semibold mb-2">Join the Waiting List</h3>
        <p className="text-sm text-muted-foreground mb-4">
          Get early access in December and receive a 10% discount
        </p>
        <form onSubmit={handleSubmit} className="flex gap-2">
          <Input
            type="email"
            placeholder="Enter your email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            required
            className="flex-1"
          />
          <Button type="submit" disabled={isSubmitting}>
            {isSubmitting ? "Joining..." : "Join"}
          </Button>
        </form>
      </div>
    );
  }

  return (
    <div className="w-full max-w-2xl mx-auto p-6 md:p-8 bg-card border-2 border-primary/30 rounded-lg shadow-primary animate-fade-in">
      <div className="flex items-center justify-center gap-3 mb-4">
        <Mail className="h-6 w-6 text-primary" />
        <h3 className="text-2xl font-bold">Join the Waiting List</h3>
      </div>
      <p className="text-center text-muted-foreground mb-6">
        Get <span className="text-primary font-semibold">early access in December</span> with an exclusive <span className="text-primary font-semibold">10% discount</span> plus access to all future modules and community updates.
      </p>
      <form onSubmit={handleSubmit} className="flex flex-col sm:flex-row gap-3">
        <Input
          type="email"
          placeholder="Enter your email address"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          required
          className="flex-1 text-base py-6"
        />
        <Button
          type="submit"
          size="lg"
          disabled={isSubmitting}
          className="bg-gradient-primary hover:shadow-primary transition-all duration-300"
        >
          {isSubmitting ? "Joining..." : "Join Waitlist"}
        </Button>
      </form>
    </div>
  );
};

export default Waitlist;
