using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Shelfie.Services.Migrations
{
    /// <inheritdoc />
    public partial class addPagesReadShelfBooks : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "PagesRead",
                table: "ShelfBooks",
                type: "int",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "PagesRead",
                table: "ShelfBooks");
        }
    }
}
