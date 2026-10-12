using Abp.Zero.EntityFrameworkCore;
using aspnetboilerplate.com.Authorization.Roles;
using aspnetboilerplate.com.Authorization.Users;
using aspnetboilerplate.com.MultiTenancy;
using aspnetboilerplate.com.Toeic;
using Microsoft.EntityFrameworkCore;

namespace aspnetboilerplate.com.EntityFrameworkCore;

public class comDbContext : AbpZeroDbContext<Tenant, Role, User, comDbContext>
{
    /* Define a DbSet for each entity of the application */
    public DbSet<ToeicExam> ToeicExams { get; set; }
    public DbSet<ToeicPart> ToeicParts { get; set; }
    public DbSet<ToeicPassageGroup> ToeicPassageGroups { get; set; }
    public DbSet<ToeicQuestion> ToeicQuestions { get; set; }
    public DbSet<ToeicQuestionOption> ToeicQuestionOptions { get; set; }
    public DbSet<ToeicExamSession> ToeicExamSessions { get; set; }
    public DbSet<ToeicExamAnswer> ToeicExamAnswers { get; set; }

    public comDbContext(DbContextOptions<comDbContext> options)
        : base(options)
    {
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.Entity<ToeicPart>()
            .HasOne(p => p.Exam)
            .WithMany(e => e.Parts)
            .HasForeignKey(p => p.ExamId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<ToeicPassageGroup>()
            .HasOne(g => g.Part)
            .WithMany(p => p.PassageGroups)
            .HasForeignKey(g => g.PartId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<ToeicQuestion>()
            .HasOne(q => q.Part)
            .WithMany(p => p.Questions)
            .HasForeignKey(q => q.PartId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<ToeicQuestion>()
            .HasOne(q => q.PassageGroup)
            .WithMany(g => g.Questions)
            .HasForeignKey(q => q.PassageGroupId)
            .OnDelete(DeleteBehavior.Restrict);

        modelBuilder.Entity<ToeicQuestionOption>()
            .HasOne(o => o.Question)
            .WithMany(q => q.Options)
            .HasForeignKey(o => o.QuestionId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<ToeicExamSession>()
            .HasOne(s => s.Exam)
            .WithMany(e => e.Sessions)
            .HasForeignKey(s => s.ExamId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<ToeicExamAnswer>()
            .HasOne(a => a.Session)
            .WithMany(s => s.Answers)
            .HasForeignKey(a => a.SessionId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<ToeicExamAnswer>()
            .HasOne(a => a.Question)
            .WithMany()
            .HasForeignKey(a => a.QuestionId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}
