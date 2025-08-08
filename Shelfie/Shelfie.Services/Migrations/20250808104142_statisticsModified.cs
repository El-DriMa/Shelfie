using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Shelfie.Services.Migrations
{
    /// <inheritdoc />
    public partial class statisticsModified : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTime>(
                name: "FirstBookReadDate",
                table: "Statistics",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "LastBookReadDate",
                table: "Statistics",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "TopAuthorId",
                table: "Statistics",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<int>(
                name: "UniqueGenresCount",
                table: "Statistics",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AlterColumn<string>(
                name: "GoalType",
                table: "ReadingChallenges",
                type: "nvarchar(max)",
                nullable: false,
                oldClrType: typeof(string),
                oldType: "varchar(20)");

            migrationBuilder.CreateIndex(
                name: "IX_Statistics_TopAuthorId",
                table: "Statistics",
                column: "TopAuthorId");

            migrationBuilder.AddForeignKey(
                name: "FK_Statistics_Authors_TopAuthorId",
                table: "Statistics",
                column: "TopAuthorId",
                principalTable: "Authors",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Statistics_Authors_TopAuthorId",
                table: "Statistics");

            migrationBuilder.DropIndex(
                name: "IX_Statistics_TopAuthorId",
                table: "Statistics");

            migrationBuilder.DropColumn(
                name: "FirstBookReadDate",
                table: "Statistics");

            migrationBuilder.DropColumn(
                name: "LastBookReadDate",
                table: "Statistics");

            migrationBuilder.DropColumn(
                name: "TopAuthorId",
                table: "Statistics");

            migrationBuilder.DropColumn(
                name: "UniqueGenresCount",
                table: "Statistics");

            migrationBuilder.AlterColumn<string>(
                name: "GoalType",
                table: "ReadingChallenges",
                type: "varchar(20)",
                nullable: false,
                oldClrType: typeof(string),
                oldType: "nvarchar(max)");
        }
    }
}
