using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Shelfie.Services.Migrations
{
    /// <inheritdoc />
    public partial class photosUserBook : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "CoverImage",
                table: "Books");

            migrationBuilder.AddColumn<string>(
                name: "PhotoUrl",
                table: "Books",
                type: "nvarchar(max)",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "PhotoUrl",
                table: "Books");

            migrationBuilder.AddColumn<byte[]>(
                name: "CoverImage",
                table: "Books",
                type: "varbinary(max)",
                nullable: true);
        }
    }
}
