using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace aspnetboilerplate.com.Migrations
{
    /// <inheritdoc />
    public partial class Add_Toeic_Entities : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "ToeicExams",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Code = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    Title = table.Column<string>(type: "nvarchar(250)", maxLength: 250, nullable: false),
                    Description = table.Column<string>(type: "nvarchar(1000)", maxLength: 1000, nullable: true),
                    DurationMinutes = table.Column<int>(type: "int", nullable: false),
                    TotalQuestions = table.Column<int>(type: "int", nullable: false),
                    Status = table.Column<int>(type: "int", nullable: false),
                    IsActive = table.Column<bool>(type: "bit", nullable: false),
                    SourceFileName = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: true),
                    CreationTime = table.Column<DateTime>(type: "datetime2", nullable: false),
                    CreatorUserId = table.Column<long>(type: "bigint", nullable: true),
                    LastModificationTime = table.Column<DateTime>(type: "datetime2", nullable: true),
                    LastModifierUserId = table.Column<long>(type: "bigint", nullable: true),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false),
                    DeleterUserId = table.Column<long>(type: "bigint", nullable: true),
                    DeletionTime = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ToeicExams", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "ToeicExamSessions",
                columns: table => new
                {
                    Id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ExamId = table.Column<int>(type: "int", nullable: false),
                    CandidateName = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    CandidateCode = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: true),
                    StartTime = table.Column<DateTime>(type: "datetime2", nullable: false),
                    EndTime = table.Column<DateTime>(type: "datetime2", nullable: true),
                    TimeSpentSeconds = table.Column<int>(type: "int", nullable: false),
                    TotalQuestions = table.Column<int>(type: "int", nullable: false),
                    CorrectAnswersCount = table.Column<int>(type: "int", nullable: false),
                    WrongAnswersCount = table.Column<int>(type: "int", nullable: false),
                    UnansweredCount = table.Column<int>(type: "int", nullable: false),
                    Score = table.Column<int>(type: "int", nullable: false),
                    Status = table.Column<int>(type: "int", nullable: false),
                    CreationTime = table.Column<DateTime>(type: "datetime2", nullable: false),
                    CreatorUserId = table.Column<long>(type: "bigint", nullable: true),
                    LastModificationTime = table.Column<DateTime>(type: "datetime2", nullable: true),
                    LastModifierUserId = table.Column<long>(type: "bigint", nullable: true),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false),
                    DeleterUserId = table.Column<long>(type: "bigint", nullable: true),
                    DeletionTime = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ToeicExamSessions", x => x.Id);
                    table.ForeignKey(
                        name: "FK_ToeicExamSessions_ToeicExams_ExamId",
                        column: x => x.ExamId,
                        principalTable: "ToeicExams",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "ToeicParts",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ExamId = table.Column<int>(type: "int", nullable: false),
                    PartNumber = table.Column<int>(type: "int", nullable: false),
                    PartTitle = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    Description = table.Column<string>(type: "nvarchar(2000)", maxLength: 2000, nullable: true),
                    OrderIndex = table.Column<int>(type: "int", nullable: false),
                    CreationTime = table.Column<DateTime>(type: "datetime2", nullable: false),
                    CreatorUserId = table.Column<long>(type: "bigint", nullable: true),
                    LastModificationTime = table.Column<DateTime>(type: "datetime2", nullable: true),
                    LastModifierUserId = table.Column<long>(type: "bigint", nullable: true),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false),
                    DeleterUserId = table.Column<long>(type: "bigint", nullable: true),
                    DeletionTime = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ToeicParts", x => x.Id);
                    table.ForeignKey(
                        name: "FK_ToeicParts_ToeicExams_ExamId",
                        column: x => x.ExamId,
                        principalTable: "ToeicExams",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "ToeicPassageGroups",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    PartId = table.Column<int>(type: "int", nullable: false),
                    Title = table.Column<string>(type: "nvarchar(300)", maxLength: 300, nullable: true),
                    PassageText = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    PassageImageUrl = table.Column<string>(type: "nvarchar(1000)", maxLength: 1000, nullable: true),
                    OrderIndex = table.Column<int>(type: "int", nullable: false),
                    CreationTime = table.Column<DateTime>(type: "datetime2", nullable: false),
                    CreatorUserId = table.Column<long>(type: "bigint", nullable: true),
                    LastModificationTime = table.Column<DateTime>(type: "datetime2", nullable: true),
                    LastModifierUserId = table.Column<long>(type: "bigint", nullable: true),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false),
                    DeleterUserId = table.Column<long>(type: "bigint", nullable: true),
                    DeletionTime = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ToeicPassageGroups", x => x.Id);
                    table.ForeignKey(
                        name: "FK_ToeicPassageGroups_ToeicParts_PartId",
                        column: x => x.PartId,
                        principalTable: "ToeicParts",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "ToeicQuestions",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    PartId = table.Column<int>(type: "int", nullable: false),
                    PassageGroupId = table.Column<int>(type: "int", nullable: true),
                    QuestionNumber = table.Column<int>(type: "int", nullable: false),
                    QuestionText = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    CorrectOption = table.Column<string>(type: "nvarchar(10)", maxLength: 10, nullable: true),
                    Explanation = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    OrderIndex = table.Column<int>(type: "int", nullable: false),
                    CreationTime = table.Column<DateTime>(type: "datetime2", nullable: false),
                    CreatorUserId = table.Column<long>(type: "bigint", nullable: true),
                    LastModificationTime = table.Column<DateTime>(type: "datetime2", nullable: true),
                    LastModifierUserId = table.Column<long>(type: "bigint", nullable: true),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false),
                    DeleterUserId = table.Column<long>(type: "bigint", nullable: true),
                    DeletionTime = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ToeicQuestions", x => x.Id);
                    table.ForeignKey(
                        name: "FK_ToeicQuestions_ToeicParts_PartId",
                        column: x => x.PartId,
                        principalTable: "ToeicParts",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_ToeicQuestions_ToeicPassageGroups_PassageGroupId",
                        column: x => x.PassageGroupId,
                        principalTable: "ToeicPassageGroups",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "ToeicExamAnswers",
                columns: table => new
                {
                    Id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    SessionId = table.Column<long>(type: "bigint", nullable: false),
                    QuestionId = table.Column<int>(type: "int", nullable: false),
                    QuestionNumber = table.Column<int>(type: "int", nullable: false),
                    SelectedOption = table.Column<string>(type: "nvarchar(10)", maxLength: 10, nullable: true),
                    CorrectOption = table.Column<string>(type: "nvarchar(10)", maxLength: 10, nullable: true),
                    IsCorrect = table.Column<bool>(type: "bit", nullable: false),
                    CreationTime = table.Column<DateTime>(type: "datetime2", nullable: false),
                    CreatorUserId = table.Column<long>(type: "bigint", nullable: true),
                    LastModificationTime = table.Column<DateTime>(type: "datetime2", nullable: true),
                    LastModifierUserId = table.Column<long>(type: "bigint", nullable: true),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false),
                    DeleterUserId = table.Column<long>(type: "bigint", nullable: true),
                    DeletionTime = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ToeicExamAnswers", x => x.Id);
                    table.ForeignKey(
                        name: "FK_ToeicExamAnswers_ToeicExamSessions_SessionId",
                        column: x => x.SessionId,
                        principalTable: "ToeicExamSessions",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_ToeicExamAnswers_ToeicQuestions_QuestionId",
                        column: x => x.QuestionId,
                        principalTable: "ToeicQuestions",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "ToeicQuestionOptions",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    QuestionId = table.Column<int>(type: "int", nullable: false),
                    OptionKey = table.Column<string>(type: "nvarchar(10)", maxLength: 10, nullable: false),
                    OptionText = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    IsCorrect = table.Column<bool>(type: "bit", nullable: false),
                    OrderIndex = table.Column<int>(type: "int", nullable: false),
                    CreationTime = table.Column<DateTime>(type: "datetime2", nullable: false),
                    CreatorUserId = table.Column<long>(type: "bigint", nullable: true),
                    LastModificationTime = table.Column<DateTime>(type: "datetime2", nullable: true),
                    LastModifierUserId = table.Column<long>(type: "bigint", nullable: true),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false),
                    DeleterUserId = table.Column<long>(type: "bigint", nullable: true),
                    DeletionTime = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ToeicQuestionOptions", x => x.Id);
                    table.ForeignKey(
                        name: "FK_ToeicQuestionOptions_ToeicQuestions_QuestionId",
                        column: x => x.QuestionId,
                        principalTable: "ToeicQuestions",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_ToeicExamAnswers_QuestionId",
                table: "ToeicExamAnswers",
                column: "QuestionId");

            migrationBuilder.CreateIndex(
                name: "IX_ToeicExamAnswers_SessionId",
                table: "ToeicExamAnswers",
                column: "SessionId");

            migrationBuilder.CreateIndex(
                name: "IX_ToeicExamSessions_ExamId",
                table: "ToeicExamSessions",
                column: "ExamId");

            migrationBuilder.CreateIndex(
                name: "IX_ToeicParts_ExamId",
                table: "ToeicParts",
                column: "ExamId");

            migrationBuilder.CreateIndex(
                name: "IX_ToeicPassageGroups_PartId",
                table: "ToeicPassageGroups",
                column: "PartId");

            migrationBuilder.CreateIndex(
                name: "IX_ToeicQuestionOptions_QuestionId",
                table: "ToeicQuestionOptions",
                column: "QuestionId");

            migrationBuilder.CreateIndex(
                name: "IX_ToeicQuestions_PartId",
                table: "ToeicQuestions",
                column: "PartId");

            migrationBuilder.CreateIndex(
                name: "IX_ToeicQuestions_PassageGroupId",
                table: "ToeicQuestions",
                column: "PassageGroupId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "ToeicExamAnswers");

            migrationBuilder.DropTable(
                name: "ToeicQuestionOptions");

            migrationBuilder.DropTable(
                name: "ToeicExamSessions");

            migrationBuilder.DropTable(
                name: "ToeicQuestions");

            migrationBuilder.DropTable(
                name: "ToeicPassageGroups");

            migrationBuilder.DropTable(
                name: "ToeicParts");

            migrationBuilder.DropTable(
                name: "ToeicExams");
        }
    }
}
