"""empty message

Revision ID: 6d641b08aaa8
Revises: d611f88dafb2
Create Date: 2023-03-06 16:45:59.256447

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '6d641b08aaa8'
down_revision = 'd611f88dafb2'
branch_labels = None
depends_on = None


def upgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    with op.batch_alter_table('item', schema=None) as batch_op:
        batch_op.add_column(sa.Column('icon', sa.String(length=128), nullable=True))

    # ### end Alembic commands ###


def downgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    with op.batch_alter_table('item', schema=None) as batch_op:
        batch_op.drop_column('icon')

    # ### end Alembic commands ###